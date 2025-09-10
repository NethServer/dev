#!/usr/bin/env bash

# DigitalOcean NS8-CI cleanup candidate lister (and optional deleter)
# Requirements: curl, jq
# This script does not use doctl because it does not run well inside GitHub Actions due
# to lack of a TTY. Instead, it uses direct API calls with curl.
#
# Usage:
#   ./ns8-ci.sh           # just list
#   ./ns8-ci.sh --delete  # list and delete

DO_DOMAIN="ci.nethserver.net"
TAG_PREFIX="NS8-CI-"
DELETE=0
DO_API_BASE="https://api.digitalocean.com/v2"


# Function to make authenticated API calls to DigitalOcean
do_api() {
  local method="${1:-GET}"
  local endpoint="$2"
  local data="$3"
  
  local curl_args=(
    -s
    -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN"
    -H "Content-Type: application/json"
    -X "$method"
  )
  
  if [[ -n "$data" ]]; then
    curl_args+=(-d "$data")
  fi
  
  # Check if the endpoint already contains a '?'
  if [[ "$endpoint" == *\?* ]]; then
    curl "${curl_args[@]}" "$DO_API_BASE$endpoint&page=1&per_page=200"
  else
    curl "${curl_args[@]}" "$DO_API_BASE$endpoint?page=1&per_page=200"
  fi
}

if [[ "$1" == "--delete" ]]; then
  DELETE=1
fi

set -e

# Get the DigitalOcean access token from environment
if [[ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]]; then
  echo "DigitalOcean access token not found. Please set DIGITALOCEAN_ACCESS_TOKEN environment variable."
  exit 1
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
  echo "curl could not be found. Please install curl."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq could not be found. Please install jq."
  exit 1
fi

# Test API access by getting account info
if ! do_api GET "/tags" | jq -e '.tags' &> /dev/null; then
  echo "Failed to authenticate with DigitalOcean API. Please check your token."
  exit 1
fi

echo "== 1. Unused tags starting with $TAG_PREFIX =="
# Get all tags and filter for NS8-CI prefix
mapfile -t ns8_tags < <(do_api GET "/tags" | jq -r '.tags[] | select(.name | startswith("'$TAG_PREFIX'")) | .name')

# Remove unused tags (no droplets attached) as a first step
for tag in "${ns8_tags[@]}"; do
  # Get droplets with this tag
  mapfile -t tag_droplets_check < <(do_api GET "/droplets?tag_name=$tag" | jq -r '.droplets[] | .id')
  if [[ ${#tag_droplets_check[@]} -eq 0 ]]; then
    echo "Unused tag: $tag"
    if [[ $DELETE -eq 1 ]]; then
      echo "-> Deleting tag $tag"
      do_api DELETE "/tags/$tag" || true
    fi
  fi
done

echo "== 2. Droplets with tags starting with $TAG_PREFIX (only 'active' and running > 3h) =="
# Get all tags with NS8-CI prefix again (in case some were deleted)
mapfile -t ns8_tags < <(do_api GET "/tags" | jq -r '.tags[] | select(.name | startswith("'$TAG_PREFIX'")) | .name')
droplet_ids=()
droplet_names=()
# threshold in seconds (3 hours)
THRESHOLD_SECONDS=10800
for tag in "${ns8_tags[@]}"; do
  # Get droplets with this tag
  mapfile -t tag_droplets < <(do_api GET "/droplets?tag_name=$tag" | jq -r '.droplets[] | "\(.id) \(.status) \(.created_at) \(.name)"')
  for entry in "${tag_droplets[@]}"; do
    id=$(echo "$entry" | awk '{print $1}')
    status=$(echo "$entry" | awk '{print $2}')
    created_at=$(echo "$entry" | awk '{print $3}')
    name=$(echo "$entry" | cut -d' ' -f4-)

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
        do_api DELETE "/droplets/$id"
      fi
    fi
  done
done

echo ""
echo "== 3. DNS records in $DO_DOMAIN without a running droplet =="
# Get all DNS records for the domain
mapfile -t records < <(do_api GET "/domains/$DO_DOMAIN/records" | jq -r '.domain_records[] | "\(.id) \(.type) \(.name)"')
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
        do_api DELETE "/domains/$DO_DOMAIN/records/$id"
      fi
    fi
  fi
done

echo ""
echo "== 4. SSH keys with names matching '*.ci.nethserver.net' not used by any droplet =="
# Get SSH keys matching '.ci.nethserver.net'
mapfile -t ssh_keys_raw < <(do_api GET "/account/keys" | jq -r '.ssh_keys[] | select(.name | contains(".ci.nethserver.net")) | "\(.id) \(.name)"')
# Get all droplet IDs for checking SSH key usage
mapfile -t all_droplet_ids < <(do_api GET "/droplets" | jq -r '.droplets[] | .id')

for ssh_entry in "${ssh_keys_raw[@]}"; do
  ssh_id=$(echo "$ssh_entry" | awk '{print $1}')
  ssh_name=$(echo "$ssh_entry" | cut -d' ' -f2-)
  ssh_used=0
  for droplet_id in "${all_droplet_ids[@]}"; do
    # Get droplet details to check SSH keys
    mapfile -t droplet_keys < <(do_api GET "/droplets/$droplet_id" | jq -r '.droplet.ssh_keys[]? | .id')
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
      do_api DELETE "/account/keys/$ssh_id"
    fi
  fi
done

echo ""
if [[ $DELETE -eq 1 ]]; then
  echo "Done. All listed resources were deleted."
else
  echo "Done. No resources were deleted (listing mode)."
fi
