---
layout: default
title: Milestones
nav_order: 2
---

# Milestones

[GitHub milestones](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/about-milestones) are a way to track progress on groups of issues or pull requests in a repository. They help in planning and managing project timelines by setting due dates and associating related tasks.

All NethServer projects use rolling releases, so milestones are used to organize the project and highlight significant goals achieved and upcoming priorities.
A milestone can be closed when all associated issues have been completed.
[Issues](/issues) can be added while the milestone is in progress, and milestones must contain both bugs and features.
Completed issues are released as they are finished, so updates are rolling; there is no need to wait for the milestone to be completed to release updates.

A milestone indicates a general objective and is useful because it concludes with an announcement to the community, informing everyone about what has been accomplished.
In general, for a stable product, a milestone is typically released every 3 months: 4 times a year.

Each open milestone should have:
- a title that contains the name of the project and the release number, e.g., `NethServer 8.3`
- a description that includes the main goals and features, like `Improved backup system and new dashboard`
- an end date that is the release date, this is usually an estimate and can be changed as needed

Please note that only issues can be assigned to a milestone, not pull requests or draft card.
To overcome this limitation, an issue with [type "Draft"](/issues/#issue-types) can be created to be associated with a milestone.
Product managers typically use draft issues to plan work for upcoming milestones.
A draft issue contains a brief description of the feature, it could not contain a detailed description or acceptance criteria.
The issue type will be changed once the analysis is complete, and it may also be split into multiple sub-issues if the work requires task separation.
