---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK032
aliases:
  - TIK032
name: Allow Ticket Template In Underscore Tickets Directory
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 6
ticket_created: 2026-06-14T07:22:09Z
ticket_updated: 2026-06-14T07:54:21Z
ticket_completed:
---
# Introduction

Support placing the ticket template directly inside the `_tickets/` directory as an alternative to the current `_templates/Ticket.md` location. This keeps the project layout cleaner for non-Obsidian users who do not need a separate templates directory, while preserving the existing `_templates/` location for Obsidian users.

# Requirements

- The `create` and `validate` subcommands accept a template located at `_tickets/Ticket.md` as a valid alternative to `_templates/Ticket.md`.
- Project root detection (walking up from CWD) checks for `_tickets/Ticket.md` in addition to `_templates/Ticket.md` as a root marker.
- When both `_templates/Ticket.md` and `_tickets/Ticket.md` exist, `_templates/Ticket.md` takes precedence (backward compatible, Obsidian-friendly default).
- The template file inside `_tickets/` does not interfere with ticket listing — the `list` subcommand skips it (it is not a valid ticket file since its filename does not match the `<code_prefix><NNN> - <subject>.md` convention).
- The `validate` subcommand skips the template file when running `--all`.
- Documentation (`Tickets.md`) is updated to describe both layout options.

# Technical Solution

TODO

# Execution Plan

TODO 