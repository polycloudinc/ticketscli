---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK010
aliases:
  - TIK010
name: Created Timestamp in Front Matter
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-13T07:20:45Z
ticket_updated: 2026-06-14T05:45:20Z
ticket_completed: 2026-06-14T05:45:20Z
---
# Introduction

Track the date and time a ticket was created as an ISO 8601 timestamp in its YAML frontmatter.

# Requirements

- When `tickets create` generates a new ticket, populate a `ticket_created` field with the current date and time in ISO 8601 UTC format with `Z` suffix (e.g. `2026-06-13T14:30:00Z`).
- The `ticket_created` field should be set at creation time and never automatically updated thereafter.
- `tickets validate` must require a `ticket_created` field and validate its format.

# Technical Solution

1. In `cmd_create`, after determining the next code and rank, capture `date -u +"%Y-%m-%dT%H:%M:%SZ"` and include it as a `ticket_created` field in the frontmatter written to the new ticket file.
2. In `_templates/Ticket.md`, add a `ticket_created:` key (empty value) so that validate does not flag it as an unknown field.
3. In `validate_one`, add a format validation: `ticket_created` must match `YYYY-MM-DDThh:mm:ssZ`.

# Execution Plan

- [ ] Add `ticket_created:` (empty value) to `_templates/Ticket.md` frontmatter.
- [ ] Update `cmd_create` to capture the current UTC timestamp (`date -u +"%Y-%m-%dT%H:%M:%SZ"`) and write a `ticket_created` field into the frontmatter.
- [ ] Update `validate_one` to validate `ticket_created` format (must match ISO 8601 UTC).
- [ ] Verify `tickets create --name "Test Timestamp"` produces a `ticket_created` field with a valid ISO 8601 UTC timestamp.
- [ ] Verify `tickets validate` fails on tickets missing `ticket_created`.
