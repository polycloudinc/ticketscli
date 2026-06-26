---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK038
aliases:
- TIK038
name: Rename Skill Folders To Tickets Dash Prefix
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-06-14T08:47:59Z'
ticket_updated: '2026-06-14T09:04:24Z'
ticket_completed: '2026-06-14T09:04:24Z'
---
# Introduction

Rename all skill folders under `.apm/skills/` from names like `create-ticket` and `list-tickets` to `tickets-create` and `tickets-list` so that ticket skills group together when lexically sorted among other non-ticket skills in the directory.

# Requirements

- Each skill folder under `.apm/skills/` is renamed from `<name>-ticket` or `<name>-tickets` to `tickets-<name>`, and `execution-plan` to `tickets-execution-plan`.
- The `update-about.sh` script and any other references that depend on folder names are updated to match.
- The `APM` synchronization from `.apm/skills/` to `.agents/skills/` is re-run after renaming to ensure both directories are consistent.
- Skill descriptions and instructional bodies remain unchanged — only folder names are renamed.

# Technical Solution

TODO

# Execution Plan

## Phase: Rename Source Folders

- [x] Rename `.apm/skills/create-ticket/` to `.apm/skills/tickets-create/`
- [x] Rename `.apm/skills/execution-plan/` to `.apm/skills/tickets-execution-plan/`
- [x] Rename `.apm/skills/list-tickets/` to `.apm/skills/tickets-list/`
- [x] Rename `.apm/skills/rank-ticket/` to `.apm/skills/tickets-rank/`
- [x] Rename `.apm/skills/review-ticket/` to `.apm/skills/tickets-review/`
- [x] Rename `.apm/skills/transition-ticket/` to `.apm/skills/tickets-transition/`

## Phase: Synchronize

- [x] Run `update-about.sh` to refresh About sections in renamed skill files
- [x] Run APM sync to regenerate `.agents/skills/` and `apm.lock.yaml`

## Phase: Verify

- [x] Confirm all 6 `tickets-*` folders exist in `.apm/skills/`
- [x] Confirm all 6 `tickets-*` folders exist in `.agents/skills/`
- [x] Confirm `modver-forgejo-workflow` in `.agents/skills/` is untouched
- [x] Confirm no stale old-named folders remain in `.apm/skills/` or `.agents/skills/`
- [x] Confirm `apm.lock.yaml` `local_deployed_files` lists new folder names 