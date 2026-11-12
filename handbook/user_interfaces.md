---
layout: default
title: User Interfaces
nav_order: 5
---

# User Interfaces
{: .no_toc }

* TOC
{:toc}

This page explains how the user interfaces of Nethesis products are designed and built. The rules
themselves live in the design systems: this page says which one applies to each product, and how
design fits into the [development workflow](index.md#general-workflow).

## Design systems

Nethesis products use two design systems:

* **[Nebula Design System](https://nethesis.github.io/nebula-design-system/)**: writing
  guidelines, glossary, colors, typography, icons, spacing, elevation and accessibility. Its Vue
  components are in the [@nethesis/vue-components](https://nethesis.github.io/vue-components/)
  library, whose Storybook shows their props and live examples. The designs are in the
  [Nebula Figma file](https://www.figma.com/design/ZRZzzlqb9GfB9Xdz6iGufh/Nebula-Design-System),
  open to the members of the Nethesis Figma team.
* **[Carbon Design System v10](https://v10.carbondesignsystem.com/)**, for NethServer 8, with the
  [ns8-ui-lib](https://nethserver.github.io/ns8-ui-lib/) components and the
  [Carbon Components Vue](https://vue.carbondesignsystem.com/vue2/) library.

The writing guidelines and the glossary of Nebula apply to every product, NethServer 8 included:

| Product | Design system | Components |
| --- | --- | --- |
| NethSecurity, My Nethesis | Nebula | `@nethesis/vue-components` |
| NethVoice CTI, NethLink | Nebula, except the components | the project's own React components |
| NethServer 8, its core and its modules | Carbon, with the Nebula writing guidelines and glossary | `ns8-ui-lib`, Carbon Components Vue |

## Design in the workflow

* An issue that changes the user interface is assigned to the UI/UX designer before development
  starts. The designer works in a sub-issue of type **Design**, whose output is a mockup, attached
  to the issue or linked from Figma (see [Issue types](issues.md#issue-types)).
* The developer builds the mockup with the components and the tokens of the design system. If the
  mockup needs something the design system does not have, such as a new component or color, ask
  the designer before writing a one-off solution: it may belong in the design system.
* When the issue implements a mockup, the developer involves the designer in testing (see
  [Developer](issues.md#developer)).

## Text and translations

* Write the interface text following the
  [writing guidelines](https://nethesis.github.io/nebula-design-system/?page=writing-guidelines)
  and the [glossary](https://nethesis.github.io/nebula-design-system/?page=glossary).
* Every string goes in the project's translation files, never as literal text in the code.
* Before a release, the strings must be on [Weblate](https://hosted.weblate.org/projects/ns8) and
  translated in English and Italian (see [Packager](issues.md#packager)).

## Accessibility

The user interfaces aim at [WCAG 2.2](https://www.w3.org/TR/WCAG22/) level AA. The
[Accessibility](https://nethesis.github.io/nebula-design-system/?page=accessibility) page of Nebula
lists the decisions specific to Nethesis products, such as how to show archived items and when a
link needs an address.

## Pull requests that change the interface

Besides the [pull request](pull_requests.md) rules, check a pull request that changes the user
interface at a narrow, phone-like width and with the keyboard only, and check its texts against
the writing guidelines and the glossary.

Screenshots or a short video of the change are welcome: they help the reviewers and the designer
see it without running the code.

## Coding agents

The `nebula-frontend` skill makes a coding agent follow Nebula when it writes or reviews a
frontend, and the writing guidelines and the glossary in NethServer 8 modules. It has been
tested in Claude Code and Codex: see [Agent skills](best_practices.md#agent-skills).

## Changing the design systems

* Nebula rules, writing guidelines and glossary: open a pull request on
  [nethesis/nebula-design-system](https://github.com/nethesis/nebula-design-system).
* Vue components: open an issue or a pull request on
  [nethesis/vue-components](https://github.com/nethesis/vue-components).
* Figma designs: ask the designer, who maintains the Figma file.
* NethServer 8 components: open an issue or a pull request on
  [NethServer/ns8-ui-lib](https://github.com/NethServer/ns8-ui-lib).
