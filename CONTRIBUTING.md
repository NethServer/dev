# NethServer issue tracker

Thank you for contributing to the NethServer project!

This GitHub repository serves on the NethServer project as official
issue-tracker.  Before opening a [new issue here](https://github.com/NethServer/dev/issues/new/choose), we suggest to discuss it on
[community.nethserver.org](http://community.nethserver.org).

**You are welcome!**

Further references:

* [Development process](http://docs.nethserver.org/projects/nethserver-devel/en/latest/development_process.html)
* [Administrator manual](http://docs.nethserver.org/en/latest/)

## NethServer 7 (EOL)

* [issues](https://github.com/NethServer/dev/issues)
* [ISO releases](http://docs.nethserver.org/en/latest/nscom_releases.html)

## NethServer 6 (EOL)

* [ns6 issue tracker archive](http://dev.nethserver.org)

## Label Management and Issue Status

When labels are added or removed from an issue, the issue's status in the projects is automatically updated:

- **Adding labels:**
  - Adding the `testing` label sets the issue status to `Testing`.
  - Adding the `verified` label sets the issue status to `Verified`.
  - Adding one of these labels automatically removes the other if it exists.

- **Removing labels:**
  - Removing the `testing` or `verified` label sets the issue status to `In Progress`.

This behavior is managed by a GitHub Actions workflow that runs the `update_issue_status.sh` script.
If an issue belongs to multiple projects, all projects are updated.

### Configuring the Personal Access Token (PAT)

To allow the workflow to update issue statuses in organization-level projects, an additional Personal Access Token (PAT) with the following minimum permissions is required:

- **`project`**: full access to projects.
- **`public_repo`**: full access to public repositories.
- **`repo`**: full access to private repositories (only required for private repositories).

To set up the PAT correctly:

1. Create a new PAT from your [GitHub account settings](https://github.com/settings/tokens), selecting the permissions listed above.
2. Add the PAT as a secret in the repository or organization, using the name `PROJECT_STATUS_BOT_TOKEN`.