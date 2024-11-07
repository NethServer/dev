---
layout: default
title: Project Management
nav_order: 2
---

# Project Management


- we are using github

- nethesis and nethserver organizations

- projects boards

The project board is a tool to track the progress of the issues and requests. It is divided into columns that represent the status of the issue. The columns are:

- **Triage**: new issues are placed here, the team will evaluate them and assign the right labels and milestone
- **Ready**: issues that are ready to be worked on, they have all the information needed to start the implementation.
  When someone starts working on an issue, they move it to the **In progress** column
- **In progress**: issues that are being worked on, they are assigned to a developer or a designer.
  If a design is needed the card should have the Mockup field set to ``Need mockup``, a designer should be assigned to the issue.
  When the mockup is ready the designer should set the Mockup field to ``Ready`` and the developer can start the implementation.
  A card assigned to a developer must be converted to an issue.
- **Backlog**: issues that are not planned for the current release
- **Done**: issues that have been completed and closed

A task inside the `NethSecurity 8` project could also have one or more extra fields:
- `Implementation`: it can be `Frontend`, `Backend` or `Frontend/Backend` to indicate the area of the code that will be affected by the issue
- `Iteration`: it indicates the iteration of the issue, the iteration is a sequence of steps to reach the final goal. The iteration usually has start and end dates
- `Mockup`: it can be empty if no mockup is needed, or `Ready` if the mockup is ready, or `Need Mockup` if the mockup is not ready yet. If an issue is marked
   as `Not ready` the developer should wait for the mockup to be ready before starting the implementation