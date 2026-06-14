---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK011
aliases:
  - TIK011
name: Ticket Updated Timestamp in Front Matter
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-13T07:20:45Z
ticket_updated: 2026-06-14T05:26:23Z
---
# Introduction

Track the date and time a ticket was last updated as an ISO 8601 timestamp in its YAML frontmatter via a `ticket_updated` field.

# Requirements

- Add a `ticket_updated` field to the ticket template (`_templates/Ticket.md` and `als-tickets-template/als-tickets-template-main/Ticket.md`).
- Whenever any CLI command mutates a ticket's state (e.g. `ticket_status`, `ticket_rank` changes), automatically update the `ticket_updated` field with the current date and time in ISO 8601 UTC format with a trailing `Z` suffix (e.g. `2026-06-13T14:30:00Z`).
- Existing tickets without a `ticket_updated` field must continue to work without errors.
- The `validate` subcommand must validate that if `ticket_updated` is present, it contains a valid ISO 8601 timestamp (same lenient behavior as `ticket_created`).

# Technical Solution

- Centralize the `ticket_updated` update logic in a helper function (e.g. `touch_ticket_updated "$ticket_file"`) that runs `sed -i` to set the field to `$(date -u +"%Y-%m-%dT%H:%M:%SZ")`.
- Call this helper from every mutation site: `cmd_create`, `cmd_transition` (status changes and rank clearing/setting), `set_ticket_rank`, and `normalize_ranks`.
- In `cmd_create`, set `ticket_updated` equal to `ticket_created` at creation time.
- In `validate_one`, validate that if `ticket_updated` is present, it contains a valid ISO 8601 timestamp (same lenient pattern as `ticket_created`).

# Execution Plan

- [x] Add `ticket_updated` field to both ticket template files.
- [x] Create a centralized `touch_ticket_updated "$ticket_file"` helper function.
- [x] Integrate `touch_ticket_updated` into `cmd_create`, `cmd_transition`, `set_ticket_rank`, and `normalize_ranks` at every mutation point.
- [x] Update `validate_one` to validate `ticket_updated` format if present (same lenient pattern as `ticket_created`).
- [x] Verify `tickets rank up --ticket TIK011` updates the `ticket_updated` timestamp.
- [x] Verify `tickets transition TIK011 "[[In Progress]]"` updates the `ticket_updated` timestamp.
- [x] Verify existing tickets without `ticket_updated` do not cause errors in list/validate/other operations.
