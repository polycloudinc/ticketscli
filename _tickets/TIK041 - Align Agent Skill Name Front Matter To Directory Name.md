---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK041
aliases:
  - TIK041
name: Align Agent Skill Name Front Matter To Directory Name
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 10
ticket_created: 2026-06-14T15:06:39Z
ticket_updated: 2026-06-14T15:06:39Z
ticket_completed:
---
# Introduction

Update the `name` YAML front matter field in each SKILL.md under .apm/skills/ to match the parent directory name, replacing the current reversed naming convention with a consistent directory-derived name.

# Requirements

- `tickets-create/SKILL.md` name must change from `create-ticket` to `tickets-create`
- `tickets-execution-plan/SKILL.md` name must change from `execution-plan` to `tickets-execution-plan`
- `tickets-list/SKILL.md` name must change from `list-tickets` to `tickets-list`
- `tickets-rank/SKILL.md` name must change from `rank-ticket` to `tickets-rank`
- `tickets-review/SKILL.md` name must change from `review-ticket` to `tickets-review`
- `tickets-transition/SKILL.md` name must change from `transition-ticket` to `tickets-transition`
- Any references to the old name values in AGENTS.md or other configuration files must be updated to match

# Technical Solution

TODO

# Execution Plan

TODO 