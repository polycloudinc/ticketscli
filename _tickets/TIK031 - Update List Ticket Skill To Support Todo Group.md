---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK031
aliases:
  - TIK031
name: Update List Ticket Skill To Support Todo Group
ticket_status: "[[Ready]]"
ticket_priority: Medium
ticket_rank: 1
ticket_created: 2026-06-14T07:20:52Z
ticket_updated: 2026-06-14T07:46:06Z
ticket_completed: 
---
# Introduction

Update the `list-tickets` agent skill to expose the `--group todo` CLI filter, which returns all non-done tickets (Backlog, Ready, and In Progress) sorted by rank. The CLI already supports this flag but the skill does not document it or map it from natural-language aliases.

# Requirements

- The `list-tickets` skill includes `todo` / `to-do` in its group mapping table with the command `tickets list --group todo`.
- Natural-language aliases for the todo group are documented (e.g., "upcoming", "remaining", "open", "outstanding").
- The priority rule in the skill accounts for `todo` as a group keyword (not confused with status-level aliases).
- The `--group todo` behavior is briefly described (returns Backlog + Ready + In Progress, sorted by rank).

# Technical Solution

TODO

# Execution Plan

TODO 