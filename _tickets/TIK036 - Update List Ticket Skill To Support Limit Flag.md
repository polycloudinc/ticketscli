---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK036
aliases:
  - TIK036
name: Update List Ticket Skill To Support Limit Flag
ticket_status: "[[Ready]]"
ticket_priority: Medium
ticket_rank: 4
ticket_created: 2026-06-14T07:26:31Z
ticket_updated: 2026-06-14T08:18:43Z
ticket_completed: 
---
# Introduction

Update the `list-tickets` agent skill to recognize numeric limits in user prompts and translate them into the CLI `--limit` flag, allowing users to request a specific number of tickets (e.g., "show top 10 tickets", "list the first 5 active tickets").

# Requirements

- The skill documentation includes the `--limit` / `-l` flag alongside `--group` and `--status` in the CLI reference section, with a note that it is not a filter and can be combined with either `--group` or `--status`.
- The skill detects numeric quantities in user prompts and extracts the limit value:
  - "show me the top 5 tickets" → `--limit 5`
  - "list the first 3 ready tickets" → `--limit 3` combined with `--status ready`
  - "give me 10 backlogs" → `--limit 10` combined with `--group backlog`
  - "show 20" → `--limit 20` (no filter)
- Ordinal phrases like "first N" and "top N" are recognized as limit indicators, not rank operations.
- `--limit` is passed alongside any group or status filter extracted from the same prompt.
- When no numeric quantity is present in the user's message, no `--limit` flag is passed (showing all matching tickets, preserving current behavior).
- Phrasing that looks like a limit but isn't (e.g., "ticket 5" meaning TIK005) is not misinterpreted — the skill distinguishes ticket codes from limit numbers by the presence of a code prefix or context.

# Technical Solution

TODO

# Execution Plan

TODO 