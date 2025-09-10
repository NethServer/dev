# Scripts Documentation

## ns8-ci.sh

### Description

`ns8-ci.sh` is a Bash script that cleans up unused DigitalOcean resources created by the NS8 CI system. It identifies and optionally deletes orphaned tags, droplets, DNS records, and SSH keys to keep the CI environment clean and reduce costs. The script uses direct DigitalOcean API calls via `curl` instead of the `doctl` CLI tool for better compatibility with CI/CD environments.

### Prerequisites

- **curl**: Standard HTTP client tool (typically pre-installed on most systems).
- **jq**: Command-line JSON processor. Install with `apt install jq` or `brew install jq`.
- **DigitalOcean API Token**: A valid DigitalOcean API token with read/write permissions.

### Usage

```bash
./ns8-ci.sh                # List mode - only show what would be cleaned up
./ns8-ci.sh --delete       # Delete mode - actually remove the identified resources
```

#### Environment Variables

The script requires a DigitalOcean API token to be set in one of these environment variables:
- `DIGITALOCEAN_ACCESS_TOKEN`

#### Example

```bash
# List orphaned resources without deleting
export DIGITALOCEAN_ACCESS_TOKEN="your_token_here"
./ns8-ci.sh

# Actually delete the orphaned resources
./ns8-ci.sh --delete
```

### How It Works

The script performs cleanup in four phases:

1. **Unused Tags**: Identifies tags starting with `NS8-CI-` that have no droplets attached and optionally removes them.

2. **Old Droplets**: Finds active droplets with NS8-CI tags that are older than 3 hours and optionally deletes them.

3. **Orphaned DNS Records**: Locates A and AAAA DNS records in `ci.nethserver.net` that don't correspond to any running droplets and optionally removes them.

4. **Unused SSH Keys**: Identifies SSH keys with names containing `.ci.nethserver.net` that aren't used by any droplets and optionally deletes them.

### Technical Details

- **API Pagination**: Handles DigitalOcean API pagination by setting `per_page=200` and `page=1` parameters.
- **Age Threshold**: Only considers droplets older than 3 hours (10,800 seconds) for deletion.
- **Safe Deletion**: Uses API calls with proper error handling to avoid accidental data loss.
- **Domain Filtering**: Only processes resources in the `ci.nethserver.net` domain.

### Output

The script provides detailed output for each phase:

- Lists all resources that match the cleanup criteria
- Shows droplet ages in human-readable format (hours)
- Confirms each deletion operation when `--delete` mode is used
- Provides summary statistics at completion

### Error Handling

- **Missing Dependencies**: Checks for required tools (`curl`, `jq`) before execution.
- **Authentication**: Validates API token by testing account access.
- **API Failures**: Continues processing other resources if individual API calls fail.
- **Resource Protection**: Only targets resources with specific naming patterns to avoid accidental deletion.

### Notes

- The script is designed for automated execution in CI/CD pipelines.
- Uses the DigitalOcean API v2 with Bearer token authentication.
- Implements pagination to handle accounts with many resources.
- Safe to run multiple times - only processes resources matching specific criteria.

## update_issue_status.sh

### Description

`update_issue_status.sh` is a Bash script that updates the status of a GitHub issue across all associated projects. It utilizes the GitHub CLI (`gh`) to interact with GitHub's GraphQL API.

### Prerequisites

- **GitHub CLI (`gh`)**: Ensure that the GitHub CLI is installed and authenticated. You can download it from [here](https://cli.github.com/).
- **Permissions**: The authenticated user must have access to the repository and associated projects.

### Usage

```bash
./update_issue_status.sh --owner OWNER --repo REPO --issue-number ISSUE_NUMBER --new-status NEW_STATUS
```

#### Parameters

- `--owner`: The GitHub username or organization that owns the repository.
- `--repo`: The name of the repository containing the issue.
- `--issue-number`: The number of the issue to update.
- `--new-status`: The new status to set for the issue in all associated projects.

#### Example

```bash
./update_issue_status.sh --owner NethServer --repo dev --issue-number 123 --new-status Verified
```

### How It Works

1. **Argument Parsing**: The script parses command-line arguments to obtain the required parameters.
2. **Authentication**: Checks for the presence of the `gh` CLI and ensures it is authenticated.
3. **Retrieve Issue Node ID**: Uses GraphQL queries to fetch the node ID of the specified issue.
4. **Fetch Associated Projects**: Retrieves a list of all projects that the issue is associated with.
5. **Update Status in Projects**:
   - For each project:
     - Retrieves the item ID corresponding to the issue.
     - Finds the ID of the `Status` field.
     - Obtains the option ID for the desired new status.
     - Updates the issue's status in the project using a GraphQL mutation.
6. **Completion**: Outputs the status of each update and completes execution.

### Output

The script provides informative output at each step, including:

- Confirmation of parsed arguments.
- IDs retrieved for the issue, projects, fields, and options.
- Success or warning messages during the update process.

### Error Handling

- **Missing Arguments**: The script checks for all required arguments and displays usage instructions if any are missing.
- **Authentication Errors**: If the `gh` CLI is not installed or authenticated, the script exits with an error message.
- **GraphQL API Failures**: Errors in API calls are caught, and appropriate messages are displayed.

### Notes

- The script assumes that the `Status` field exists in the associated projects and that the `NEW_STATUS` provided is a valid option.
- If the `NEW_STATUS` is not found in a project's status options, the script will issue a warning and continue to the next project.
- Ensure that the `gh` CLI has the necessary scopes and permissions to perform the operations.
