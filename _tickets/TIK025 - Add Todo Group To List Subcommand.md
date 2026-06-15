---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK025
aliases:
  - TIK025
name: Add Todo Group To List Subcommand
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-14T04:54:29Z
ticket_updated: 2026-06-14T05:45:20Z
ticket_completed: 2026-06-14T05:45:20Z
---
# Introduction

Add a `todo` group filter to the `list` subcommand that combines backlog, ready, and in-progress tickets into a single view, sorted by rank.

# Requirements

- `--group todo` returns tickets with status `[[Backlog]]`, `[[Ready]]`, or `[[In Progress]]`, sorted by rank
- The `todo` group is added to the known group values alongside backlog, active, and done
- Fuzzy matching supports the `todo` group (e.g., `--group tod` resolves to `todo`)
- The usage/help text for `list` documents the `todo` group
- Existing groups (backlog, active, done) remain unchanged in behavior

# Technical Solution

TODO

# Execution Plan

TODO 