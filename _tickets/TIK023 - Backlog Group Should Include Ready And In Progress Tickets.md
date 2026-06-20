---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK023
aliases:
- TIK023
name: Backlog Group Should Include Ready And In Progress Tickets
ticket_status: '[[Won''t Fix]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-06-14T04:20:19Z'
ticket_updated: '2026-06-14T05:45:20Z'
ticket_completed: '2026-06-14T05:45:20Z'
---
# Introduction

The `--group backlog` switch on the `tickets list` command currently only returns tickets with `[[Backlog]]` status. It should return all non-terminal tickets: `[[Backlog]]`, `[[Ready]]`, and `[[In Progress]]`.

# Requirements

- `tickets list --group backlog` must return tickets with status `[[Backlog]]`, `[[Ready]]`, and `[[In Progress]]`
- Tickets with terminal statuses (`[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]`) must still be excluded from the backlog group
- Existing behavior of the `--group active` and `--group done` switches must remain unchanged

# Technical Solution

TODO

# Execution Plan

TODO 