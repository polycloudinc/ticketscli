---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK011
aliases:
  - TIK011
name: Last Updated Timestamp in Front Matter
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 4
ticket_created: 2026-06-13T07:20:45Z
---
# Introduction

Track the date and time a ticket was last updated as an ISO 8601 timestamp in its YAML frontmatter.

# Requirements

- When a ticket's frontmatter is modified — e.g. `ticket_status`, `ticket_priority`, or `ticket_rank` changes — update a `last_updated` field with the current date and time in ISO 8601 format (e.g. `2026-06-13T14:30:00Z`).
- The `last_updated` field should be set to the current time on every frontmatter change.
- Existing tickets without a `last_updated` field should continue to work without errors.

# Technical Solution

In any function that modifies ticket frontmatter (rank changes, status updates), also set `last_updated` to `date -u +"%Y-%m-%dT%H:%M:%SZ"` in the YAML frontmatter.

# Execution Plan

- [ ] Identify all code paths that modify ticket frontmatter (rank, status, priority).
- [ ] Update each path to write a `last_updated` field with the current UTC ISO 8601 timestamp.
- [ ] Verify `tickets rank up --ticket TIK011` updates the `last_updated` timestamp.
- [ ] Verify existing tickets without a `last_updated` field do not cause errors in list/kanban/other operations.
