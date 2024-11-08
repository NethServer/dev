---
layout: default
title: Issues
nav_order: 3
---

# Issues

Gestione Issue:
Eliminazione della label "bug" in favore del tipo "bug".
Spostamento delle issue di NethLink nel tracker di NethServer con l'etichetta nethlink.


## Issues

An issue is a formal description of a known problem, or desired
feature, inside a tracker. There are two kind of issues:

- **Bug**: 
  describes a defect of the software; it must lead to a
  resolution of the problem. For example, a process crashing under certain
  conditions.

- **Feature/Enhancement**:
  describes an improvement of the current code or an entirely new
  feature. For example, remove a harmless warning of a running process or
  designing a new UI panel.

Bugs and enhancements will always produce some code changes inside one or more
Git repositories.

Each repository is associated with one or more container images. Changes to the code
produce new releases of modules.


### Do I need to open a new issue?

Yes, if what you’re talking about will produce some code.
By the way, it’s perfectly reasonable not to fill issues for
occasional small fixes, like typos in translations.

When implementing small fixes, always avoid commits to the main branch.
Open a [pull request](#pull-requests) and carefully describe the problem.
Creation of issues can be avoided only for trivial fixes which require
no QA effort.

Issues are not a to-do list. Issues track the status changes of a job, the
output of the job will be a new container image resolving the issue itself.
If you are exploring some esoteric paths for new feature or hunting
something like a [heisenbug](http://en.wikipedia.org/wiki/Heisenbug>),
please open a discussion with your thoughts.
Then create a new issue only when you’re ready to write a formal description
and produce some output object.

A process for a new feature should be something like this:

- open a new topic on [http://community.nethserver.org](http://community.nethserver.org) and discuss it

- if a feature is planned for the future it is also recorded in a [project
  draft card](https://github.com/orgs/NethServer/projects/8)

- ongoing development can be tracked inside a [draft pull request](#draft-pull-requests)

- once the work on the feature starts, open the issue on GitHub
  [https://github.com/NethServer/dev/issues/new](https://github.com/NethServer/dev/issues/new)


### Writing issues

How to write a bug report:

* Apply the **bug** label
* Point to the right software component with the associated version
* Describe the error, and how to reproduce it
* Describe the expected behavior
* If possible, suggest a fix or workaround
* If possible, add a piece of system output (log, command, etc)
* Text presentation matters: it makes the whole report more readable
  and understandable

How to write a feature or enhancement:

* Everybody should understand what you’re talking about: describe the
  feature with simple words using examples
* If possible, add links to external documentation
* Text presentation and images matter: they make the whole report more readable
  and understandable

More information:

* [Mozilla bug writing guidelines](https://bugzilla.mozilla.org/page.cgi?id=bug-writing.html)
* [Fedora howto file a bug](https://docs.fedoraproject.org/en-US/quick-docs/howto-file-a-bug/)


### Issue priority

Bugs should always have priority over features.

The priority of a bug depends on:

* security: if it's a security bug, it should have maximum priority
* number of affected users: more affected users means more priority


### Issue tracker

The NethServer project is hosted on GitHub and is constituted by many Git
repositories.  We set one of them to be the issue tracker:

[https://github.com/NethServer/dev](https://github.com/NethServer/dev)

Issues created on it help coordinating the development process, determining
who is in charge of what.

Issues recorded in the tracker are a fundamental source of information for
future changes and a reference for documentation and support requests.

Issues recorded as project draft cards constitute the project roadmap and
are published here:

[https://github.com/orgs/NethServer/projects/8](https://github.com/orgs/NethServer/projects/8)

### Issue labels

Issues can be tagged using a set of well-known labels:

- `bug`: a defect of the software
- `testing`: packages are available from testing repositories (see [QA section](#qa-team-member-testing))
- `verified`: all test cases were verified successfully (see [QA section](#qa-team-member-testing)
- `invalid`: invalid issue, not a bug, duplicate or wontfix. Add a detailed description and link
  to other related issue when using this tag.

An issue without `bug` label is considered a new feature or an enhancement.

Before introducing new labels, please discuss them with the development team
and make sure to describe carefully the new label inside the [label page](https://github.com/NethServer/dev/labels).


### Process the issue

After an issue is filed in the tracker, it goes through the hands of teammates who assume various roles. While the same person may take on multiple roles simultaneously, we prefer to distribute responsibilities as much as possible.

#### Developer

The *Developer*.

- Sets *Assignee* to himself.

- Sets the *Project* to `NethServer 8`

- Bundle his commits as one or more GitHub [pull requests](#pull-request)

- For *enhancements*, writes the test case (for *bugs* the procedure to
  reproduce the problem should be already set).

- Writes and updates the [documentation](#documentation) associated with the code.

If the issue is not valid, it must be closed using the **invalid** label.
A comment must convey the reason why it is invalid, like *"duplicate of (URL of issue), wontfix because ..."*.


#### QA team member (testing)

The *QA team member*.

* Takes an issue with label **testing** and adds themselves to the *Assignee*
  field

* Tests the package, following the test case documentation written by the
  *Developer*.

* Tests the documentation changes, if present

* When test finishes they remove the **testing** label.  If the test is
  *successful*, they set the **verified** label, otherwise they alert the
  *Developer* and the *Packager* to plan a new process iteration.


#### Packager

The *Packager* coordinates the *Developer* and *QA member* work.  After the
*Developer* opens one or more pull requests:

* Selects issues with open pull requests

* Reviews the pull request code and merges it
  The CI will build and upload a new container image

After the *QA member* has completed the testing phase:

* Takes an issue with label **verified**

* Commits a *release tag* (see [Module version numbering rules](#module-version-numbering-rules)).

* Pushes the *release tag* and commits to GitHub

* Merges the documentation changes in the `nethserver/ns8-docs` repo. Also
  publishes the documentation by pushing the `latest` branch, if needed

* Closes the issue, specifying the list of released modules

When the package is CLOSED, all related [documentation](#documentation) must be in place.

At any time of the issue lifecycle they ensure that there are no release
conflict with other issues.




## New modules

The NethServer community encourages the development of new applications
(modules). Learn more about [how ideas become NS8
applications](../modules/certification/).

## Documentation

The developer must take care to write all documentation on:

* README.md inside the repository
* Administrator Manual

An application should not be released as "stable" until all documentation
(developer, admin, user) is complete.

## Update rules

Updates to NS8 core and modules (applications) must follow these rules:

0. New features, enhancements, and bug fixes must not change the behavior
   of existing systems.

0. New behaviors must be enabled through explicit and documented sysadmin
   actions.

0. Modules must support updates from any previous release within the same
   major release.
