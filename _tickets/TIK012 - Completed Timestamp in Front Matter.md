---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK012
aliases:
- TIK012
name: Completed Timestamp in Front Matter
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-06-13T07:20:45Z'
ticket_updated: '2026-06-14T05:45:20Z'
ticket_completed: '2026-06-14T05:45:20Z'
---
# Introduction

Track the date and time a ticket was completed as an ISO 8601 timestamp in its `ticket_completed` frontmatter field. When a ticket transitions to a done status (`[[Complete]]`, `[[Won't Fix]]`, `[[Duplicate]]`), the field is set to the current UTC time. When a ticket transitions back to an active status (`[[Backlog]]`, `[[Ready]]`, `[[In Progress]]`), the field is cleared.

# Requirements

- Add a `ticket_completed` field to `_templates/Ticket.md` after `ticket_updated`.
- When a ticket's status transitions to `[[Complete]]`, `[[Won't Fix]]`, or `[[Duplicate]]`, set `ticket_completed` to the current UTC date and time in ISO 8601 format (e.g. `2026-06-13T14:30:00Z`).
- When a ticket's status transitions to `[[Backlog]]`, `[[Ready]]`, or `[[In Progress]]`, clear the `ticket_completed` field (set to empty).
- The `ticket_completed` field must be treated as optional by validate — existing tickets without it must not produce errors.
- Existing tickets without a `ticket_completed` field should continue to work without errors.

# Technical Solution

In `cmd_transition()` in `tickets.sh`, after the status label mapping block:

1. **Terminal status (`complete|duplicate|wontfix`):** Set `ticket_completed` to the current UTC ISO 8601 timestamp via `date -u +"%Y-%m-%dT%H:%M:%SZ"`. If the field already exists, replace it (covers re-completion of reopened tickets).
2. **Active status (`backlog|ready|inprogress`):** Clear `ticket_completed` by setting it to empty.

In `_templates/Ticket.md`, add `ticket_completed:` on its own line after `ticket_updated:`.

In `cmd_validate()`, add `ticket_completed` to the list of optional fields (alongside `ticket_updated`) so tickets without it are not flagged.

# Execution Plan

- [x] Add `ticket_completed:` to `_templates/Ticket.md` after `ticket_updated:`.
- [x] Update `cmd_validate()` to treat `ticket_completed` as optional (skip in the missing-fields check, like `ticket_updated`).
- [x] Update `cmd_transition()` to set `ticket_completed` to the current UTC ISO 8601 timestamp when transitioning to `complete`, `duplicate`, or `wontfix`.
- [x] Update `cmd_transition()` to clear `ticket_completed` (set to empty) when transitioning to `backlog`, `ready`, or `inprogress`.
- [x] Verify setting a ticket to `[[Complete]]` populates the `ticket_completed` field.
- [x] Verify setting a ticket to `[[Won't Fix]]` populates the `ticket_completed` field.
- [x] Verify setting a ticket to `[[Duplicate]]` populates the `ticket_completed` field.
- [x] Verify transitioning a done ticket back to `[[Backlog]]` clears the `ticket_completed` field.
- [x] Verify transitioning a done ticket back to `[[Ready]]` clears the `ticket_completed` field.
- [x] Verify transitioning a done ticket back to `[[In Progress]]` clears the `ticket_completed` field.
- [x] Verify `tickets validate` does not flag tickets missing `ticket_completed`.
- [x] Verify `tickets validate` does not flag tickets with `ticket_completed` as an unknown field.
