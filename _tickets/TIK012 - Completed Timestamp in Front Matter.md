---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK012
aliases:
  - TIK012
name: Completed Timestamp in Front Matter
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 6
ticket_created: 2026-06-13T07:20:45Z
---
# Introduction

Track the date and time a ticket was completed as an ISO 8601 timestamp in its YAML frontmatter. This applies when a ticket reaches `[[Complete]]`, `[[Won't Fix]]`, or `[[Duplicate]]` status.

# Requirements

- When a ticket's status transitions to `[[Complete]]`, `[[Won't Fix]]`, or `[[Duplicate]]`, set a `completed` field with the current date and time in ISO 8601 format (e.g. `2026-06-13T14:30:00Z`).
- The `completed` field should only be set once, when the terminal status is first reached. It should not be overwritten if the ticket is reopened.
- Existing tickets without a `completed` field should continue to work without errors.

# Technical Solution

In the status-update code path, detect transitions to terminal statuses (`[[Complete]]`, `[[Won't Fix]]`, `[[Duplicate]]`) and write a `completed` field with the current UTC ISO 8601 timestamp (`date -u +"%Y-%m-%dT%H:%M:%SZ"`). Skip if the field already exists to avoid overwriting the original completion time on subsequent edits.

# Execution Plan

- [ ] Update the status-change code path to detect terminal status transitions and write a `completed` timestamp.
- [ ] Ensure the `completed` field is not overwritten if it already exists.
- [ ] Verify setting a ticket to `[[Complete]]` populates the `completed` field.
- [ ] Verify setting a ticket to `[[Won't Fix]]` populates the `completed` field.
- [ ] Verify setting a ticket to `[[Duplicate]]` populates the `completed` field.
- [ ] Verify existing tickets without a `completed` field do not cause errors.
