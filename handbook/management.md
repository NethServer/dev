---
layout: default
title: Project Management
nav_order: 2
---

# Project Management
{: .no_toc }

* TOC
{:toc}

## Roles and responsibilities

### Product Manager

The Product Manager oversees the overall development process, ensuring that the product meets the needs of users and stakeholders. They prioritize features and bug fixes, coordinate between different teams, and ensure that the project stays on track and aligns with the strategic goals.
They are responsible for defining the product vision, creating the roadmap, and communicating with the community.

### User

The User is the person who interacts with the software, uses the features, and reports issues or requests new features. They provide feedback on the usability and functionality of the software.

### Developer

The Developer is responsible for implementing code changes, writing test cases, and updating documentation. They ensure that issues are correctly assigned and documented, and they handle invalid issues appropriately.

### QA Team Member (Testing)

The QA Team Member is responsible for testing packages and documentation changes. They verify that the code works as expected and meets the required standards before it is released.
This role is crucial for ensuring the quality of the software and preventing regressions.
Anyone can be a QA Team Member, but usually is one of the following:
- a support engineer
- a developer: beware, the developer should not test their own code!
- a user who reported bugs
- the Product Manager who sponsored a feature

### Packager

The Packager is a developer that coordinates the work between developers and QA Team Members. They review and merge code changes, manage release tags, and ensure that documentation is updated and published. They also handle the final steps of closing issues and releasing modules.
Usually the packager is the same person as the developer, but in some cases, it can be a different person.

## Meetings

A weekly meeting is recommended for each project, scheduled by the Product Manager.
The meeting should include the following topics:
- review of the current status of the project
- discussion of any blockers or issues
- planning for the next steps

A good practice is to schedule the meeting on fixed day and time, so everyone can plan their work accordingly.
If there is nothing to discuss, the team can just meet for a quick check-in.

## Project boards

Project boards are used to track the progress of issues and requests. They are divided into columns that represent the status of the issue. The active project boards are:

- [NethServer](https://github.com/orgs/NethServer/projects/8): NethServer is container orchestration platform, it contains the core modules and many applications, including NethVoice
- [NethVoice](https://github.com/orgs/NethServer/projects/11): NethVoice is a VoIP platform, it's a module of NethServer and it contains many sub-modules like the PBX, a CTI and a desktop client
- [NethSecurity](https://github.com/orgs/NethServer/projects/10): NethSecurity is an UTM firewall, based on OpenWrt

### Project views

All projects have some common views:

- **Current**: it shows the current status of the project, it contains all the issues inside the ongoing [milestone](/milestones); this view uses a kanban board

- **Backlog**: it contains all the issues that are not assigned to a [milestone](/milestones) yet, or that are not ready to be worked on; this view uses a list of [issues](/issues)

The team working on a project can decide to add more views if needed, for example, a view for the next milestone, or a view to measure the team load.

Each column contains a set of cards, each card represents an issue or a feature request.

A card can have two date fields:
- `Start date`: the date when the task has been started or is planned to start
- `End date`: an estimation of the date when the task will be completed or the date when the task has been completed

#### Current view

The project is divided into columns that represent the status of the card.
A card can be an issue, a feature request, a bug report, or a task.
The columns are:

- **ToDo**: new issues are placed here, the team will evaluate them and assign the right [labels](/issues/#issue-labels) and [milestone](/milestones).
- **In Progress**: issues that are being worked on, they are assigned to a developer or a designer.
- **Testing**: issues that are ready for testing. The QA Team will verify that the code works as expected and meets the required standards.
- **Verified**: issues that have passed testing and are verified to be working correctly, this issues are ready to be released by the packager.
- **Done**: issues that have been completed and closed.

Cards are grouped by open milestones, and the cards are ordered by priority.

When an issue gets the "testing" label, it is automatically moved to the "Testing" column.
When an issue gets the "verified" label, it is automatically moved to the "Verified" column.
If both labels are removed, the issue is moved back to the "In Progress" column.

When a milestone is closed, all the cards in the "Done" column can be archived, and the changelog will be given by the milestone itself.

The view should list all planned (open) milestones, with the current milestone at the top.
This view should be shared with the community to show the progress of the project.

#### Backlog view

The backlog view contains all the draft cards or issues that are not assigned to a milestone yet.
Usually the backlog view can contains also draft cards the roughly describe a feature or a bug, but they are not ready to be worked on yet.

The Product Manager, with the help of the team, will review the backlog view and assign the right milestone to the cards.
