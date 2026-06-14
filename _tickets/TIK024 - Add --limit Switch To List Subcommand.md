---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK024
aliases:
  - TIK024
name: Add --limit Switch To List Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 8
ticket_created: 2026-06-14T04:35:04Z
---
# Introduction

Add a `--limit` switch to the `list` subcommand so users can cap the number of tickets displayed, returning only the top N tickets after filtering and sorting by rank.

# Requirements

- `list` supports a `--limit N` (or `-l N`) flag where `N` is a positive integer (>= 1)
- `--limit` rejects any value that is not a positive integer with a descriptive validation error
- Applying `--limit` restricts output to the first N tickets after filtering and sorting by rank
- If the limit exceeds the number of matching tickets, all matching tickets are displayed with no error
- Omitting `--limit` preserves the current behavior (all matching tickets are shown)
- The usage/help text for `list` documents the new flag

# Technical Solution

TODO

# Execution Plan

TODO 