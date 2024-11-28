---
layout: default
title: Issues
nav_order: 3
---

# Issues
{: .no_toc }

* TOC
{:toc}

## Issue trackers

An issue is a formal description of a known problem, or desired
feature, inside a tracker.

Available trackers are:

- [NethServer and NethVoice](https://github.com/NethServer/issues)
- [NethSecurity](https://githu.com/NethServer/issues)

## Issue types

There two main type of issues:

- **Bug**: Describes a defect of the software that must lead to a resolution of the problem. For example, a process crashing under certain conditions.

- **Feature**: Describes an improvement of the current code or an entirely new feature. For example, removing a harmless warning of a running process or designing a new UI panel.

Bug and feature issues will always produce some code changes inside one or more Git repositories.
Usually this type of issue are the parent issue for one or more sub-issues.

The QA of the code should always test the parent issue, not the sub-issues.
Still, sub-issues of type **Design** can pass to the testing state when the mockup needs to be reviewed. When the mockup is approved, the sub-issue can be 
moved to verified state or directly closed.

Sub-issues are tasks that are part of the parent issue. They can be of different types:

- **Design**: Design the UI; the output of this task should be a mockup that can be attached to the issue as image or link to an external tool like Figma.

- **Backend**: Backend implementation, like a new API endpoint or package update.

- **Draft**: An issue that needs to be refined. It can be assigned to a milestone. If the issue is not planned, so it does not have a milestone, it should be created as a draft card in the project board.

- **Frontend**: Frontend implementation, like a new UI panel or a new page.

- **Task**: A specific piece of work, like a code refactoring or a documentation update. 


## Opening issues

An issue can track a feature, a bug, or a task.

Issues are not a to-do list. Issues track the status changes of a job, the
output of the job will be a new container image, in case of NethServer, resolving the issue itself.
If you are exploring some esoteric paths for new feature or hunting
something like a [heisenbug](http://en.wikipedia.org/wiki/Heisenbug>),
please open a discussion with your thoughts.
Then create a new issue only when you’re ready to write a formal description
and produce some output object.

### Feature

A process for a new feature should be something like this:

- open a new topic on [http://community.nethserver.org](http://community.nethserver.org) and discuss it

- if a feature is planned for the future it is also recorded in a [project
  draft card](https://github.com/orgs/NethServer/projects/8)

- ongoing development can be tracked inside a [draft pull request](/pull_requests/#draft-pull-requests)

- once the work on the feature starts, open the issue on GitHub:
  - for [NethServer or NethVoice](https://github.com/NethServer/dev/issues/new)
  - for [NethSecurity](https://github.com/NethServer/nethsecurity/issues/new)


### Bug

A good bug report is half the solution. Sometimes it’s hard to write a good
a bug report, but it’s worth the effort. Here are some tips:

- open a new topic on [http://community.nethserver.org](http://community.nethserver.org) and discuss it

- if the bug is confirmed, a developer will open issue on GitHub:
  - for [NethServer or NethVoice](https://github.com/NethServer/dev/issues/new)
  - for [NethSecurity](https://github.com/NethServer/nethsecurity/issues/new)

- if the bug is not confirmed, the discussion could be closed with a comment explaining why it is not a bug or why it is not reproducible

Is always a good idea to open an issue for a bug, if the fix will produce some code.
By the way, it’s perfectly reasonable not to fill issues for
occasional small fixes, like typos in translations.

When implementing small fixes, always avoid commits to the main branch.
Open a [pull request](/pull_requests) and carefully describe the problem.
Creation of issues can be avoided only for trivial fixes which require
no QA effort.

## Writing issues

How to write a bug report:

* Choose the **Bug** type
* Point to the right software component with the associated version
* Describe the error, and how to reproduce it
* Describe the expected behavior
* If possible, suggest a fix or workaround
* If possible, add a piece of system output (log, command, etc)
* Text presentation matters: it makes the whole report more readable
  and understandable

How to write a feature or enhancement:

* Choose the **Feature** type
* Everybody should understand what you’re talking about: describe the
  feature with simple words using examples
* If possible, add links to external documentation
* Text presentation and images matter: they make the whole report more readable
  and understandable

More information:

* [Mozilla bug writing guidelines](https://bugzilla.mozilla.org/page.cgi?id=bug-writing.html)
* [Fedora howto file a bug](https://docs.fedoraproject.org/en-US/quick-docs/howto-file-a-bug/)


## Issue priority

Bugs should always have priority over features.

The priority of a bug depends on:

* security: if it's a security bug, it should have maximum priority
* number of affected users: more affected users means more priority


## Issue labels

Issues can be tagged using a set of well-known labels:

- `testing`: packages are available from testing repositories (see [QA section](#qa-team-member-testing))
- `verified`: all test cases were verified successfully (see [QA section](#qa-team-member-testing)
- `milestone goal`: the issue is one of the goals for the milestone, it should be completed before the milestone deadline

Before introducing new labels, please discuss them with the development team
and make sure to describe carefully the new label inside the [NethServer label page](https://github.com/NethServer/dev/labels) or [NethSecurity label page](https://github.com/NethServer/nethsecurity/labels).

## Process the issue

After an issue is filed in the tracker, it goes through the hands of teammates who assume various roles. While the same person may take on multiple roles simultaneously, we prefer to distribute responsibilities as much as possible.

An issue can be assigned to anyone at any time. The same apply do draft cards.
If a developer assigns a draft issue to themselves, it indicates their intention to work on it eventually.
This helps the developer keep track of pending tasks to address after completing their current task.

When an issue is marked as in progress, it means that the assignee is actively working on it.
Multiple assignee can collaborate on the same issue.

Thus, the assignee not only shows who is responsible for a task but also assists in future planning and task management.

The process of handling an issue is described in the following sections.

### Developer

The *Developer*.
- Sets *Assignee* to himself.
- Sets the *Project* to `NethServer`, `NethVoice`, or `NethSecurity`.
- Bundle his commits as one or more GitHub [pull requests](/pull_request). 
- For *features** *enhancements*, writes the test case (for *bugs* the procedure to
  reproduce the problem should be already set).
- After the pull request has been approved and merged, the developer should:
  - remove all assignee from the issue
  - set the **testing** label
  It's the developer's responsibility to ensure that someone from the QA team will test the package.
- Writes and updates the documentation associated with the code:
  - README.md inside the repository
  - Administrator Manual
  - Developer Manual, if needed
  - User Manual, if needed

If the issue is not valid, it must be closed using ``Closed as not planned``.
A comment must convey the reason why it is invalid, like *"duplicate of (URL of issue), wontfix because ..."*.

### QA team member (testing)

The *QA team member*.
* Takes an issue with label **testing** and adds themselves to the *Assignee*
  field
* Tests the package, following the test case documentation written by the
  *Developer*.
* Tests the documentation changes, if present
* When test finishes they remove the **testing** label.  If the test is
  *successful*, they set the **verified** label, otherwise they alert the
  *Developer* and the *Packager* to plan a new process iteration.

### Packager

The *Packager* coordinates the *Developer* and *QA member* work.  
After the *QA member* has completed the testing phase:
* Takes an issue with label **verified**
* Commits a *release tag* (see [version numbering rules](../version_numbering)).
* Pushes the *release tag* and commits to GitHub
* Merges the documentation changes in the documentation repo. Also
  publishes the documentation by pushing the `latest` branch, if needed.
  Documentation repositories:
  - [NethServer and NethVoice](https://github.com/NethServer/ns8-docs/)
  - [NethSecurity](https://github.com/NethServer/nethsecurity-docs/)
  An application should not be released as "stable" until all documentation
(developer, admin, user) is complete.
* Closes the issue, specifying the list of released modules

When the package is CLOSED, all related documentation must be in place.

At any time of the issue life-cycle they ensure that there are no release
conflict with other issues.

## Security: report vulnerabilities

If you find a security vulnerability, please report it to the security team by writing an email to sviluppo@nethesis.it
or by using GitHub dedicated security report tools:

- [NethServer and Nethvoice](https://github.com/NethServer/dev/security/advisories/new)
- [NethSecurity](https://github.com/NethServer/nethsecurity/security/advisories/new)

Please, **do not report security vulnerabilities as GitHub issues**.

### Handling security vulnerabilities

The security team will evaluate the report and will contact the reporter to discuss the issue.
If the issue is confirmed, the security team will work with the development team to fix the issue.
The security team will evaluate the severity of the issue and will decide if the issue should be kept private until a fix is available.

This is the process:
1. open a draft security advisory on GitHub
2. assign the issue to the development team
3. the development team will work on the fix
4. the security team will review the fix
5. the fix will be released as soon as possible and announced to the users using community channels; the fix usually includes new packages along with a new image
6. depending on the severity of the issue, the development team will decide how long to wait before a full disclosure, usually between 15 and 30 days, to give
   users time to update their systems.

The disclosure will be be done by publishing the security advisory on GitHub and eventually by updating the community channels