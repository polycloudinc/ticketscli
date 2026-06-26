---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK032
aliases:
- TIK032
name: Relocate Ticket Template To Tickets Directory
ticket_status: '[[Backlog]]'
ticket_priority: Medium
ticket_rank: 5
ticket_created: '2026-06-14T07:22:09Z'
ticket_updated: '2026-06-15T14:53:50Z'
ticket_completed: null
---
# Introduction

Relocate the ticket template from `_templates/Ticket.md` to `_tickets/Ticket.md`. The system should no longer use or expect a `_templates/` directory. The template lives alongside tickets in the tickets directory, simplifying the project layout.

# Requirements

- The `create` and `validate` subcommands read the template from `<tickets-dir>/Ticket.md` (default `_tickets/Ticket.md`). The `_templates/Ticket.md` path is no longer supported.
- Project root detection (walking up from CWD) checks for `<tickets-dir>/Ticket.md` (default `_tickets/Ticket.md`) as the root marker.
- `cmd_init` creates the template at `<tickets-dir>/Ticket.md` instead of `_templates/Ticket.md`.
- All subcommands that iterate `*.md` files in the tickets directory (`list`, `validate --all`, `normalize_ranks`, `statistics snapshot`) skip `Ticket.md` since it is not a valid ticket file (its filename does not match the `<code_prefix><NNN> - <subject>.md` convention).
- `cmd_create` skips `Ticket.md` when scanning for the highest existing ticket code and rank.
- Documentation (`Tickets.md`) is updated to remove all references to `_templates/` and describe the new template location.
- Agent skill files that reference `_templates/` are updated.

# Technical Solution

TODO

# Execution Plan

TODO 