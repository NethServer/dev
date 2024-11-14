---
layout: default
title: Pull Requests
nav_order: 4
---

# Pull Requests
{: .no_toc }

* TOC
{:toc}

A pull request is a way to submit contributions to a project. It is a request to merge a set of changes into the main branch of the project.

In NethServer, each repository is associated with one or more container images: changes to the code
produce new releases of modules.
In NethSecurity, most of the work is done on the main repository: changes to the code produce new packages or a new image.

## Pull requests

A Pull Request (PR) is the main method of submitting code contributions to NethServer projects. It is a request to merge a set of changes into the main branch of the project.

You can find an overview of the whole workflow [here](/index#general-workflow).

### Submitting a pull request

When submitting a PR, check that:
1. PR is submitted against the main branch (for current stable release)
2. PR title contains a brief explanation of the feature, fix or enhancement
3. PR comment contains a link to the related issue, in the form:
   - for NethServer and NethVoice ``NethServer/dev#<number>`` like NethServer/dev#1122
   - for NethtSecurity ``#<number>`` when committing to the main repository, like `#1145` or ``NethServer/nethsecurity#<number>`` like ``NethServer/nethsecurity#1155`` when committing to a module repository
4. PR comment describes the changes and how the feature is supposed to work
5. Multiple dependent PRs in multiple repositories must include the dependencies between them in the description
6. Select at least one PR reviewer (GitHub suggestions are a usually good)
7. Select yourself as the initial PR assignee: this will help to track the PR status and who is in charge of it

### Managing an open pull request

After submitting a PR, before it is merged:
1. If enabled, automated build process must pass
   - If the build fails, check the error and try to narrow down the reason
   - If the failure is due to an infrastructure problem, please contact a developer who will help you
2. Another developer must review the pull request to make sure it:
   - Works as expected
   - Doesn't break existing stuff
   - The code is reasonably readable by others developers
   - The commit history is clean and adheres to [commit message rules](#commit-message-rules)
3. The PR must be approved by a developer with commit access to NethServer on GitHub:
   - Any comment raised by a developer has been addressed before the pull request is ready to merge

### Merging a pull request

When merging a PR, make sure to copy the issue reference inside the merge commit comment body, this step will be used by automation tools:
- to write notification about published modules inside the referenced issue
- to automatically create modules changelog

If the commit history is not clear enough, or you want to easily revert the whole work, it's acceptable
to squash before merge. Please make sure the issue reference is present inside the comment of the squashed commit.

Also, avoid adding the issue references directly inside non-merge commit messages to have a clean GitHub reference graph.

Example of a good merge commit:
```
  commit xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  Merge: xxxxxxx yyyyyyy
  Author: Mighty Developer <mighty.developer@netheserver.org>
  Date:   Thu Dec 14 17:12:19 2017 +0100

      Merge pull request #87 from OtherDev/branchXY

      Add new excellent feature 

      NethServer/dev#1122
```
Example of a merged PR with squash:
```
  commit xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  Author: Mighty Developer <mighty.developer@netheserver.org>
  Date:   Thu Dec 14 17:12:19 2017 +0100

    Another feature (#89)

    NethServer/dev#1133
```

### Draft pull requests

The use of draft pull requests is recommended to share an on-going development.
Draft pull requests can be used to test possible implementations of features that do not have an issue yet.
If the draft pull request does not reference an issue it must have an assignee.