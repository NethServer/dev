#!/bin/bash

# Move project items from "ToDo" to "In Progress" when the issue is
# open, has at least one assignee and is referenced by an open pull
# request (either linked from the Development sidebar or mentioning it)
# in a repository of the same organization that owns the project.

# Exit immediately if a command exits with a non-zero status
set -e
set -o pipefail

# Check if 'gh' CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    exit 1
fi

DRY_RUN=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --owner) OWNER="$2"; shift ;;
    --project-number) PROJECT_NUMBER="$2"; shift ;;
    --dry-run) DRY_RUN=true ;;
    *) echo "Error: Unknown argument: $1"; exit 1 ;;
  esac
  shift
done

# Check required arguments
if [ -z "$OWNER" ] || [ -z "$PROJECT_NUMBER" ]; then
  echo "Usage: $0 --owner OWNER --project-number PROJECT_NUMBER [--dry-run]"
  echo "Example: $0 --owner NethServer --project-number 8 --dry-run"
  exit 1
fi

FROM_STATUS="ToDo"
TO_STATUS="In Progress"

# Get project ID, Status field ID and target option ID
read -r PROJECT_ID STATUS_FIELD_ID STATUS_OPTION_ID < <(gh api graphql -F org="$OWNER" -F projectNumber="$PROJECT_NUMBER" -f query='
  query($org: String!, $projectNumber: Int!) {
    organization(login: $org) {
      projectV2(number: $projectNumber) {
        id
        field(name: "Status") {
          ... on ProjectV2SingleSelectField {
            id
            options {
              id
              name
            }
          }
        }
      }
    }
  }' | jq -r --arg STATUS "$TO_STATUS" '.data.organization.projectV2 |
    [.id, .field.id, (.field.options[] | select(.name==$STATUS) | .id)] | @tsv')

if [ -z "$STATUS_OPTION_ID" ]; then
  echo "Error: Status option '$TO_STATUS' not found in Project #$PROJECT_NUMBER."
  exit 1
fi

# Collect open, assigned issues in the source status: "ITEM_ID ISSUE_ID URL"
ITEMS_QUERY='
  query($org: String!, $projectNumber: Int!, $endCursor: String) {
    organization(login: $org) {
      projectV2(number: $projectNumber) {
        items(first: 100, after: $endCursor) {
          nodes {
            id
            status: fieldValueByName(name: "Status") {
              ... on ProjectV2ItemFieldSingleSelectValue {
                name
              }
            }
            content {
              ... on Issue {
                id
                url
                state
                assignees(first: 1) {
                  totalCount
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  }'

CANDIDATES=$(gh api graphql --paginate -F org="$OWNER" -F projectNumber="$PROJECT_NUMBER" -f query="$ITEMS_QUERY" |
  jq -r --arg STATUS "$FROM_STATUS" '.data.organization.projectV2.items.nodes[] |
    select(.status.name==$STATUS and .content.state=="OPEN" and .content.assignees.totalCount > 0) |
    [.id, .content.id, .content.url] | @tsv')

if [ -z "$CANDIDATES" ]; then
  echo "No assigned issues in '$FROM_STATUS'."
  exit 0
fi

PRS_QUERY='
  query($issueId: ID!) {
    node(id: $issueId) {
      ... on Issue {
        closedByPullRequestsReferences(first: 20) {
          nodes {
            url
            state
            repository {
              owner {
                login
              }
            }
          }
        }
        timelineItems(itemTypes: [CROSS_REFERENCED_EVENT, CONNECTED_EVENT], last: 100) {
          nodes {
            ... on CrossReferencedEvent {
              source {
                ... on PullRequest {
                  url
                  state
                  repository {
                    owner {
                      login
                    }
                  }
                }
              }
            }
            ... on ConnectedEvent {
              subject {
                ... on PullRequest {
                  url
                  state
                  repository {
                    owner {
                      login
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }'

MOVED=0
while IFS=$'\t' read -r ITEM_ID ISSUE_ID ISSUE_URL; do
  OPEN_PRS=$(gh api graphql -F issueId="$ISSUE_ID" -f query="$PRS_QUERY" |
    jq -r --arg OWNER "$OWNER" '.data.node |
      [.closedByPullRequestsReferences.nodes[], (.timelineItems.nodes[] | .source // .subject)] |
      map(select(.state=="OPEN" and .repository.owner.login==$OWNER) | .url) | unique | join(" ")')

  if [ -z "$OPEN_PRS" ]; then
    continue
  fi

  echo "- $ISSUE_URL -> '$TO_STATUS' (open PRs: $OPEN_PRS)"
  MOVED=$((MOVED + 1))

  if [ "$DRY_RUN" = "true" ]; then
    continue
  fi

  gh api graphql --silent -f query='
    mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $projectId,
        itemId: $itemId,
        fieldId: $fieldId,
        value: { singleSelectOptionId: $optionId }
      }) {
        projectV2Item {
          id
        }
      }
    }' -F projectId="$PROJECT_ID" -F itemId="$ITEM_ID" -F fieldId="$STATUS_FIELD_ID" -F optionId="$STATUS_OPTION_ID"
done <<< "$CANDIDATES"

echo "Items moved to '$TO_STATUS': $MOVED$([ "$DRY_RUN" = "true" ] && echo " (dry run)")"
