#!/usr/bin/env bash

# DigitalOcean NS8-CI cleanup candidate lister (and optional deleter)
# Requirements: doctl, jq
#
# Usage:
#   ./doctl-ns8-ci.sh           # just list
#   ./doctl-ns8-ci.sh --delete  # list and delete

DO_DOMAIN="ci.nethserver.net"
TAG_PREFIX="NS8-CI-"
DELETE=0

if [[ "$1" == "--delete" ]]; then
  DELETE=1
fi

set -e
# Default $doctl_cmd context (can be overridden by exporting DOCTL_CONTEXT)
DOCTL_CONTEXT="${DOCTL_CONTEXT:-sviluppo}"

# If running in CI environment, require DIGITALOCEAN_ACCESS_TOKEN to be set
if [[ -n "$CI" ]]; then
    if [[ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]]; then
      echo "CI environment detected but DIGITALOCEAN_ACCESS_TOKEN is not set."
      exit 1
    fi
    echo "CI environment detected. Using DIGITALOCEAN_ACCESS_TOKEN for authentication."
    doctl_cmd="doctl --context $DOCTL_CONTEXT --access-token $DIGITALOCEAN_ACCESS_TOKEN"
else
  doctl_cmd="doctl --context $DOCTL_CONTEXT"
fi

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
  echo "doctl could not be found. Please install doctl and configure it with access token."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq could not be found. Please install jq."
  exit 1
fi


# Check if doctl can access DigitalOcean
if ! $doctl_cmd account get &> /dev/null; then
  echo "doctl cannot access DigitalOcean. Attempting to authenticate..."
  $doctl_cmd auth init
  echo "Re-checking doctl access..."
  if ! $doctl_cmd account get &> /dev/null; then
    echo "Auth failed."
    exit 1
  fi
fi

echo "== 1. Unused tags starting with $TAG_PREFIX =="
mapfile -t ns8_tags < <($doctl_cmd compute tag list --format Name --no-header | grep "^$TAG_PREFIX" || true)
# Remove unused tags (no droplets attached) as a first step
for tag in "${ns8_tags[@]}"; do
  mapfile -t tag_droplets_check < <($doctl_cmd compute droplet list --tag-name "$tag" --format ID --no-header || true)
  if [[ ${#tag_droplets_check[@]} -eq 0 ]]; then
    echo "Unused tag: $tag"
    if [[ $DELETE -eq 1 ]]; then
      echo "-> Deleting tag $tag"
      $doctl_cmd compute tag delete "$tag" -f || true
    fi
  fi
done

echo "== 2. Droplets with tags starting with $TAG_PREFIX (only 'active' and running > 3h) =="
mapfile -t ns8_tags < <($doctl_cmd compute tag list --format Name --no-header | grep "^$TAG_PREFIX" || true)
droplet_ids=()
droplet_names=()
# threshold in seconds (3 hours)
THRESHOLD_SECONDS=10800
for tag in "${ns8_tags[@]}"; do
  # Request fields via JSON so we reliably get created_at; parse with jq to: ID Status CreatedAt Name
  mapfile -t tag_droplets < <($doctl_cmd compute droplet list --tag-name "$tag" -o json | jq -r '.[] | "\(.id) \(.status) \(.created_at) \(.name)"')
  for entry in "${tag_droplets[@]}"; do
    id=$(echo "$entry" | awk '{print $1}')
    status=$(echo "$entry" | awk '{print $2}')
    created_at=$(echo "$entry" | awk '{print $3}')
    name=$(echo "$entry" | cut -d' ' -f4-)
    echo "$entry"
    echo "id=$id status=$status created_at=$created_at name=$name"

    # Skip if we couldn't parse fields
    if [[ -z "$id" || -z "$created_at" ]]; then
      continue
    fi

    # Only consider active droplets
    if [[ "$status" != "active" ]]; then
      continue
    fi

    # Parse created_at to epoch and compute age
    created_epoch=$(date -d "$created_at" +%s 2>/dev/null || true)
    if [[ -z "$created_epoch" ]]; then
      # fallback: skip if date parsing fails
      continue
    fi
    now_epoch=$(date +%s)
    age=$(( now_epoch - created_epoch ))

    if (( age > THRESHOLD_SECONDS )); then
      droplet_ids+=("$id")
      droplet_names+=("$name")
      # show human-friendly age in hours (with integer hours)
      age_hours=$(( age / 3600 ))
      echo "Droplet: $name ($id) [tag: $tag] status=$status age=${age_hours}h"
      if [[ $DELETE -eq 1 ]]; then
        echo "-> Deleting droplet $name ($id)"
        $doctl_cmd compute droplet delete "$id" -f
      fi
    fi
  done
done

echo ""
echo "== 3. DNS records in $DO_DOMAIN without a running droplet =="
mapfile -t records < <($doctl_cmd compute domain records list "$DO_DOMAIN" --format ID,Type,Name --no-header)
for record in "${records[@]}"; do
  id=$(echo "$record" | awk '{print $1}')
  type=$(echo "$record" | awk '{print $2}')
  name=$(echo "$record" | awk '{print $3}')
  if [[ "$type" == "A" || "$type" == "AAAA" ]]; then
    found=0
    for dname in "${droplet_names[@]}"; do
      if [[ "$dname" == "$name" ]]; then
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      echo "Orphan DNS $type record: $name.$DO_DOMAIN (record id: $id)"
      if [[ $DELETE -eq 1 ]]; then
        echo "-> Deleting DNS record $id ($name.$DO_DOMAIN)"
        $doctl_cmd compute domain records delete "$DO_DOMAIN" "$id" -f
      fi
    fi
  fi
done

echo ""
echo "== 3. SSH keys with names matching '^*ci.nethserver.net-deploy' not used by any droplet =="
# Collect SSH keys matching '.ci.nethserver.net' using the same template you provided
mapfile -t ssh_keys_raw < <($doctl_cmd compute ssh-key list --format ID,Name --no-header | grep '\.ci\.nethserver\.net' || true)
mapfile -t all_droplet_ids < <($doctl_cmd compute droplet list --format ID --no-header)

for ssh_entry in "${ssh_keys_raw[@]}"; do
  ssh_id=$(echo "$ssh_entry" | awk '{print $1}')
  ssh_name=$(echo "$ssh_entry" | cut -d' ' -f2-)
  ssh_used=0
  for droplet_id in "${all_droplet_ids[@]}"; do
    mapfile -t droplet_keys < <($doctl_cmd compute droplet get "$droplet_id" --format SSHKeys --no-header | tr ',' '\n' | awk '{print $1}')
    for dkey in "${droplet_keys[@]}"; do
      if [[ "$dkey" == "$ssh_id" ]]; then
        ssh_used=1
        break 2
      fi
    done
  done
  if [[ $ssh_used -eq 0 ]]; then
    echo "Unused SSH key: $ssh_name ($ssh_id)"
    if [[ $DELETE -eq 1 ]]; then
      echo "-> Deleting SSH key $ssh_name ($ssh_id)"
      $doctl_cmd compute ssh-key delete "$ssh_id" -f
    fi
  fi
done

echo ""
if [[ $DELETE -eq 1 ]]; then
  echo "Done. All listed resources were deleted."
else
  echo "Done. No resources were deleted (listing mode)."
fi
