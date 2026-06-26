---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK007
aliases:
- TIK007
name: Agent Skill For Tickets
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-06-09T12:41:42Z'
ticket_updated: '2026-06-14T05:45:20Z'
ticket_completed: '2026-06-14T05:45:20Z'
---
# Introduction

Create an agent skill that guides AI coding agents on how to work with the tickets system. The skill must apply locally within this repository and also be managed as a reusable component published as an APM package so other projects can consume it.

# Requirements

- An agent skill must be created at `.agents/skills/tickets/SKILL.md` following the SKILL.md format used by existing skills (frontmatter with `name` and `description`, followed by markdown instructions). This file must be a symlink to the canonical source in the component directory so that local edits to the skill take effect immediately without requiring a reinstall.
- A new module `als-tickets-skill` must be created containing a component `als-tickets-skill-main` (following the existing `module-name/component-name-main/` convention used by `als-tickets-cli` and `als-tickets-template`).
- The component must contain an `apm.yml` manifest and a `.apm/skills/tickets/SKILL.md` file. APM packages deploy the contents of `.apm/` into `.agents/` in the consuming project, so the skill is installed as `.agents/skills/tickets/SKILL.md`.
- The component must include its own `component.yaml` identity file following OPMC conventions.
- A Forgejo workflow `.forgejo/workflows/publish-skills.yaml` must be created to publish the component as an APM package. The workflow triggers on push to master when `apm.yml`, `.apm/**`, the workflow file itself, or `version` changes, and also supports `workflow_dispatch`. It sources the `version` file, computes `VERSION_REVISION` from `git rev-list HEAD --count`, creates a git tag `v${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION}`, and pushes the tag. The workflow runs in a `node:22` container. Other projects consume the package by referencing the git repo URL and tag.
- The skill must cover: running `tickets list` to view tickets, reading a specific ticket's details, understanding status values and their meanings, updating ticket status as work progresses, creating new tickets with `tickets create`, and using `tickets rank` subcommands to manage priority.
- The skill must capture the ticket lifecycle: tickets start as `[[Backlog]]`, move to `[[Ready]]` when slated for work, `[[In Progress]]` when actively being implemented, and `[[Complete]]` when done. `[[Duplicate]]` and `[[Won't Fix]]` are terminal states for tickets that will not be worked.
- Agents must be instructed to update the execution plan checkboxes in a ticket as tasks are completed, and to set `ticket_status` to `[[Complete]]` when all execution plan items are done.
- Agents must be instructed to always verify their work by running `tickets list` after making ticket changes, and to reference ticket codes (e.g. `TIK001`) when communicating about tickets to the user.

# Technical Solution

Create the `als-tickets-skill/als-tickets-skill-main/` component directory with a `component.yaml` identity file, an `apm.yml` manifest, and `.apm/skills/tickets/SKILL.md` containing the canonical skill content (APM deploys `.apm/` → `.agents/`). Create a symlink at `.agents/skills/tickets/SKILL.md` pointing to `als-tickets-skill/als-tickets-skill-main/.apm/skills/tickets/SKILL.md` so that edits to the component source are immediately reflected in the local agent skills loader. Create `.forgejo/workflows/publish-skills.yaml` that sources `version`, computes a tag from git history, and pushes it. The SKILL.md frontmatter uses `name: tickets` and a concise `description` describing when the skill should be invoked.

# Execution Plan

- [x] Review existing skills in `.agents/skills/` to understand the SKILL.md conventions.
- [x] Create the `als-tickets-skill/als-tickets-skill-main/` module and component directory.
- [x] Create `component.yaml` for the new component following the same conventions as `als-tickets-cli` and `als-tickets-template`.
- [x] Create `apm.yml` manifest in the component directory.
- [x] Draft the SKILL.md content covering CLI commands, status lifecycle, and agent workflow.
- [x] Place the canonical SKILL.md in the component directory under `.apm/skills/tickets/SKILL.md`.
- [x] Create a symlink at `.agents/skills/tickets/SKILL.md` → `als-tickets-skill/als-tickets-skill-main/.apm/skills/tickets/SKILL.md` for instant local feedback.
- [x] Create `.forgejo/workflows/publish-skills.yaml` that sources `version`, computes a tag from `git rev-list HEAD --count`, and pushes it.
- [x] Verify the skill includes concrete, copy-pasteable CLI examples for all key operations.
- [x] Verify `tickets list` shows TIK007 after creating it.
