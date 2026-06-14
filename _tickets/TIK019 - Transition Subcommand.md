---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK019
aliases:
  - TIK019
name: Transition Subcommand
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-14T03:29:55Z
ticket_updated: 2026-06-14T04:05:38Z
---
# Introduction

Add a `transition` subcommand to the tickets CLI for changing a ticket's `ticket_status` with built-in business rules.

# Requirements

- `tickets transition --ticket <code> --target <status>` updates the ticket's `ticket_status` frontmatter field.
- The `--ticket` switch identifies the ticket by its code (e.g., `TIK019`).
- The `--target` switch accepts the status to transition to.
- Valid `--target` values (canonical lowercased): `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`. Case-insensitive fuzzy matching applies, identical to the `--status` flag in the `list` subcommand (exact match first, then substring match).
- Any transition from any status to any status is allowed — no restrictions.
- When transitioning to a done status (`complete`, `duplicate`, `wontfix`):
  - Clear the `ticket_rank` field.
  - Trigger rank normalization (reuse `normalize_ranks()`).
- When transitioning from a done status back to an active status (`backlog`, `ready`, `inprogress`):
  - If `ticket_rank` is empty, set it to `max_existing_rank + 1`.
- If the ticket is already in the target status, the command prints a message and exits without changes.
- Accept `-d|--tickets-dir` (default `_tickets`) consistent with all other subcommands.
- No post-transition schema validation required.

# Technical Solution

- Map canonical target values to frontmatter format:
  | Canonical | Frontmatter |
  |---|---|
  | `backlog` | `"[[Backlog]]"` |
  | `ready` | `"[[Ready]]"` |
  | `inprogress` | `"[[In Progress]]"` |
  | `complete` | `"[[Complete]]"` |
  | `duplicate` | `"[[Duplicate]]"` |
  | `wontfix` | `"[[Won't Fix]]"` |

- Reuse the existing fuzzy-matching logic from `cmd_list()` for `--target`.
- Reuse `normalize_ranks()` for renormalization after transitioning to a done status.
- Reuse `find_ticket_by_code()` for resolving `--ticket`.

# Execution Plan

- [x] Add canonical-to-frontmatter status mapping function
- [x] Add `cmd_transition()` handler function
- [x] Register `transition` subcommand in dispatch table
- [x] Handle done-transition: clear rank, normalize
- [x] Handle re-activation: assign `max_rank + 1`
- [x] Test all transitions manually with a sample ticket 