---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK010
aliases:
  - TIK010
name: Created Timestamp in Front Matter
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 3
---
# Introduction

Track the date and time a ticket was created as an ISO 8601 timestamp in its YAML frontmatter.

# Requirements

- When `tickets create` generates a new ticket, populate a `created` field with the current date and time in ISO 8601 format (e.g. `2026-06-13T14:30:00Z` or `2026-06-13T14:30:00+00:00`).
- The `created` field should be set at creation time and never automatically updated thereafter.
- Existing tickets without a `created` field should continue to work without errors.

# Technical Solution

In `cmd_create`, after determining the next code and rank, capture `date -u +"%Y-%m-%dT%H:%M:%SZ"` and include it as a `created` field in the frontmatter written to the new ticket file.

# Execution Plan

- [ ] Update `cmd_create` to capture the current UTC timestamp and write a `created` field into the frontmatter.
- [ ] Verify `tickets create --name "Test Timestamp"` produces a `created` field with a valid ISO 8601 timestamp.
- [ ] Verify existing tickets without a `created` field do not cause errors in list/kanban/other operations.
