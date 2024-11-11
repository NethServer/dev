---
layout: default
title: Developer Handbook
nav_order: 1
---

# Nethesis Developer Handbook
{: .no_toc }

[Nethesis](https://www.nethesis.it) is an Italian company specializing in the development and suppoer of Open Source software solutions. 
Nethesis offers a range of services including consulting, support, and training to ensure that their clients can effectively implement and benefit from their solutions.

This handbook is intended to provide a comprehensive guide to the development process at Nethesis.

* TOC
{:toc}

## Open Source development process

The development process described in this document is common to all projects. Some projects might differ in specific details
based on the underlying implementation (e.g., package or module numbering), these specifics are covered in dedicated sections.

This process aims to outline how the development department operates, is intended for any contributor, and helps delineate the workflow
for new developers or casual contributors.

The development process adopted by this project follows the Open Source development methodology. 
This involves collaborative development, where the source code is made available to the public, allowing anyone to inspect, modify, and enhance the code. 
Contributions from the community are encouraged and managed through a transparent and inclusive process,
typically using version control systems like Git and platforms like GitHub.

## Community driven development

There are two communities that contribute significantly:

- [NethServer Community](https://community.nethserver.org/): This community consists of users and developers who volunteer their time. The forum is in English and open to everyone. It is the primary place for feature requests, support, and bug reports. Without this community, the project would not exist.

- [Nethesis Partner Community](https://partner.nethesis.it/): This community includes partners and customers. The forum is in Italian and focuses on commercial support, feature requests, and support. They provide substantial contributions to the project roadmap as they financially support the project. Access is reserved for partners.

The main tool used is [GitHub](https://github.com), where the code is hosted, and the development process is managed. Repositories are organized into organizations. Nethesis has two organizations:

- [NethServer](https://github.com/nethserver/): it hosts most of the Open Source code, access is open to everyone
- [Nethesis](https://github.com/nethesis/): it hosts both Open Source and closed source code, including private repositories. The access is reserved to Nethesis members

## General workflow

The development workflow for Nethesis projects involves several steps to ensure quality and efficiency. Here is a detailed description of the process:

1. **Bug or Feature Collection**: Issues are collected from internal channels (private chats, helpdesk) or external channels such as community forums.
2. **Issue Formalization**: The collected issues are formalized into GitHub issues. This task is usually delegated to a developer but can also be performed by other roles such as the project manager. The issue must be added to a project board and can be added to a milestone if it must be planned for a specific release.
3. **Issue Assignment**: The issue is assigned to a developer who implements the solution in a separate branch and opens a pull request. If the issue requires changes to the user interface, the issue is assigned to a UI/UX designer before starting the development process.
4. **Code Review**: The code is subjected to a code review by one or more developers to ensure quality and adherence to coding standards.
5. **Pull Request Approval and Merge**: Once the pull request is approved, it is merged into the main branch.
6. **Automated Build and Test Process**: The build and test processes are automatically executed to verify the changes.
7. **Quality Assurance (QA)**: The output of the build process, whether a module or a package, is subjected to QA testing.
8. **Release or Rework**:
  - If the QA process is successful, the module or package is released, and the issue is closed.
  - If the QA process fails, the issue is returned to the developer for correction, and the process restarts from step 3.
  
## Tools and methodologies

The development process is heavily based on the use of Git and GitHub and follows the GitHub flow methodology.
GitHub Flow is a lightweight, branch-based workflow for managing work on GitHub. It involves creating a branch for each 
feature or bug fix, committing changes to that branch, opening a pull request to discuss and review the changes,
and merging the branch into the main branch once approved. It emphasizes collaboration, continuous delivery,
and integration. For more details, visit [GitHub Flow official documentation](https://docs.github.com/en/get-started/using-github/github-flow).

## Handbook structure

This guide is divided into the following sections:

- [Project management](./management): organization of the project, roles and responsibilities
- [Milestones](./milestones): definition, management, and release process
- [Issues](./issues): definition, issue tracker, how and when to open a new issue, processing the issue
- [Pull Requests](./pull_requests): submitting, managing, merging, draft pull requests
- [Version Numbering Rules](./version_numbering): stable releases, pre-releases or testing releases
- [Commit Message Style Guide](./commit_messages): rules for composing a good commit message


## Specific developer manuals

Project-specific developer manuals are available for the following projects:

- [NethServer](https://nethserver.github.io/ns8-core/)
- [NethSecurity](https://dev.nethsecurity.org)