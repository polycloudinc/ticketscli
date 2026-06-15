---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK031
aliases:
  - TIK031
name: Update List Ticket Skill To Support Todo Group
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-14T07:20:52Z
ticket_updated: 2026-06-14T07:54:21Z
ticket_completed: 2026-06-14T07:54:21Z
---
# Introduction

Update the `list-tickets` agent skill to expose the `--group todo` CLI filter, which returns all non-done tickets (Backlog, Ready, and In Progress) sorted by rank. The CLI already supports this flag but the skill does not document it or map it from natural-language aliases.

# Requirements

- The `list-tickets` skill includes `todo` in its group mapping table with the command `tickets list --group todo`.
- Natural-language aliases for the todo group are documented (e.g., "upcoming", "remaining", "open", "outstanding").
- The priority rule in the skill accounts for `todo` as a group keyword (not confused with status-level aliases).
- The `--group todo` behavior is briefly described (returns Backlog + Ready + In Progress, sorted by rank).

# Technical Solution

TODO

# Execution Plan

## CLI and Group Mapping

- [x] Add `tickets list --group todo` to the CLI examples block with a comment describing it returns Backlog + Ready + In Progress sorted by rank
- [x] Add `todo` row to the Group mapping table

## Alias Tables and Priority

- [x] Add `todo` row to the Group Aliases table: `upcoming, remaining, open, outstanding`
- [x] Remove `todo, to-do, upcoming` from the backlog row in Group Aliases (they now map to the todo group)
- [x] Remove `todo, to-do, upcoming` from the backlog row in Status Aliases (they now map to the todo group)
- [x] Update the priority rule so `todo` maps to `--group todo` rather than `--status backlog`