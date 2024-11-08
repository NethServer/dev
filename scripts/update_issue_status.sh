#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if 'gh' CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    exit 1
fi

# Check for required arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 OWNER REPO ISSUE_NUMBER NEW_STATUS"
    echo "Example: $0 NethServer dev 123 Verified"
    exit 1
fi

# Input arguments
OWNER="$1"
REPO="$2"
ISSUE_NUMBER="$3"
NEW_STATUS="$4"

echo "Owner: $OWNER"
echo "Repository: $REPO"
echo "Issue Number: $ISSUE_NUMBER"
echo "New Status: $NEW_STATUS"

# Authenticate with GitHub (assumes 'gh' is already authenticated)
export GH_TOKEN=$(gh auth token)

# Set the issue node ID
ISSUE_NODE_ID=$(gh api graphql -f owner="$OWNER" -f repo="$REPO" -F issueNumber="$ISSUE_NUMBER" -f query='
  query($owner: String!, $repo: String!, $issueNumber: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $issueNumber) {
        id
      }
    }
  }' --jq '.data.repository.issue.id')

if [ -z "$ISSUE_NODE_ID" ]; then
  echo "Error: Failed to retrieve issue node ID."
  exit 1
fi

echo "Issue Node ID: $ISSUE_NODE_ID"

# Get projects associated with the issue
PROJECT_NUMBERS=$(gh api graphql -f owner="$OWNER" -f repo="$REPO" -F issueNumber="$ISSUE_NUMBER" -f query='
  query($owner: String!, $repo: String!, $issueNumber: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $issueNumber) {
        projectItems(first: 100) {
          nodes {
            project {
              number
            }
          }
        }
      }
    }
  }' --jq '.data.repository.issue.projectItems.nodes[].project.number')

if [ -z "$PROJECT_NUMBERS" ]; then
  echo "No projects found for issue #$ISSUE_NUMBER."
  exit 0
fi

echo "Projects associated with the issue: $PROJECT_NUMBERS"

# Update the status in each project
for PROJECT_NUMBER in $PROJECT_NUMBERS; do
  echo "Processing Project #$PROJECT_NUMBER"

  # Get item ID
  ITEM_ID=$(gh api graphql -F org="$OWNER" -F projectNumber="$PROJECT_NUMBER" -f query='
    query($org: String! , $projectNumber: Int!) {
      organization(login: $org) {
        projectV2(number: $projectNumber) {
          items(first: 100) {
            nodes {
              id
              content {
                ... on Issue {
                  id
                }
              }
            }
          }
        }
      }
    }' --jq '.data.organization.projectV2.items.nodes[] | select(.content.id=="'$ISSUE_NODE_ID'") | .id')

  if [ -z "$ITEM_ID" ]; then
    echo "Warning: Item ID not found in Project #$PROJECT_NUMBER."
    continue
  fi

  echo "Item ID in Project: $ITEM_ID"

  # Get Status field ID
  STATUS_FIELD_ID=$(gh api graphql -F org="$OWNER" -F projectNumber="$PROJECT_NUMBER" -f query='
    query($org: String!, $projectNumber: Int!) {
      organization(login: $org) {
        projectV2(number: $projectNumber) {
          fields(first: 100) {
            nodes {
              ... on ProjectV2FieldCommon {
                id
                name
              }
            }
          }
        }
      }
    }' --jq '.data.organization.projectV2.fields.nodes[] | select(.name=="Status") | .id')


  if [ -z "$STATUS_FIELD_ID" ]; then
    echo "Warning: 'Status' field not found in Project #$PROJECT_NUMBER."
    continue
  fi

  echo "Status Field ID: $STATUS_FIELD_ID"

  # Get Status option ID
  STATUS_OPTION_ID=$(gh api graphql -F org="$OWNER" -F projectNumber="$PROJECT_NUMBER" -F fieldId="$STATUS_FIELD_ID" -f query='
    query($org: String!, $projectNumber: Int!) {
      organization(login: $org) {
        projectV2(number: $projectNumber) {
          fields(first: 100) {
            nodes {
              ... on ProjectV2SingleSelectField {
                id
                name
                options {
                  id
                  name
                }
              }
            }
          }
        }
      }
    }' --jq ".data.organization.projectV2.fields.nodes[] | select(.name==\"Status\") | .options[] | select(.name==\"$NEW_STATUS\") | .id")

  if [ -z "$STATUS_OPTION_ID" ]; then
    echo "Warning: Status option '$NEW_STATUS' not found in Project #$PROJECT_NUMBER."
    continue
  fi

  echo "Status Option ID: $STATUS_OPTION_ID"

  # Get project ID
  PROJECT_ID=$(gh api graphql -F org="$OWNER" -F projectNumber="$PROJECT_NUMBER" -f query='
    query($org: String!, $projectNumber: Int!) {
      organization(login: $org) {
	projectV2(number: $projectNumber) {
	  id
	}
      }
    }' --jq '.data.organization.projectV2.id')

  if [ -z "$PROJECT_ID" ]; then
    echo "Warning: Project ID not found for Project #$PROJECT_NUMBER."
    continue
  fi

  echo "Project ID: $PROJECT_ID"

  # Update the status of the item in the project
  gh api graphql --method POST -f query='
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

  echo "Updated status in Project #$PROJECT_NUMBER to '$NEW_STATUS'."
done

echo "Script execution completed."
