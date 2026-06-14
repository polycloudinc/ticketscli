---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK019
aliases:
  - TIK019
name: Transition Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 6
ticket_created: 2026-06-14T03:29:55Z
---
# Introduction

Add a `transition` subcommand to the tickets CLI for changing a ticket's `ticket_status` with built-in business rules.

# Requirements

- `tickets transition --ticket <code> --status <status>` updates the ticket's `ticket_status` frontmatter field.
- Valid status values: `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix` (case-insensitive, with fuzzy matching matching the behavior of the list subcommand's `--status` flag).
- When transitioning to a done status (`complete`, `duplicate`, `wontfix`), clear the `ticket_rank` field.
- When transitioning from a done status back to an active status (`backlog`, `ready`, `inprogress`), if `ticket_rank` is empty, set it to `max_existing_rank + 1`.
- If the ticket is already in the target status, the command prints a message and exits without changes.

# Technical Solution

TODO

# Execution Plan

TODO 