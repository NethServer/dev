---
layout: default
title: Commit Messages Style Guide
nav_order: 6
---

# Commit Messages Style Guide

A commit message is a brief description of the changes made in a [commit](https://git-scm.com/docs/git-commit). It is a way to communicate the purpose of the change to other developers.
A good commit message helps to understand the changes made in the commit and why they were made.

All Nethesis projects follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard for commit messages.

## Conventional Commits standard

Conventional Commits is a specification for writing standardized commit messages. It provides a set of rules for creating an explicit commit history, which makes it easier to write automated tools on top of. By following this convention, you can make your commit history more readable and easier to understand.

Individual commits should contain a cohesive set of changes to the code. These
[seven rules](http://chris.beams.io/posts/git-commit/#seven-rules) summarize how a good commit message should be composed.

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

For merge commits, and commits pushed directly to the main branch (*avoid whenever possible!*),
also add the issue reference inside the commit body.