---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK037
aliases:
  - TIK037
name: Add Summary Line To List Output
ticket_status: "[[Ready]]"
ticket_priority: Medium
ticket_rank: 2
ticket_created: 2026-06-14T08:15:10Z
ticket_updated: 2026-06-14T08:18:43Z
ticket_completed: 
---
# Introduction

Add a summary line to the tabular output of the `list` subcommand that displays the number of tickets shown and the total number of tickets found, so users can see when the `--limit` flag has restricted the displayed results.

# Requirements

- A summary line appears after the table output showing "Showing X of Y tickets" (or similar wording)
- When no `--limit` flag is used, the "showing" count equals the "total" count
- When `--limit` is used and fewer tickets are displayed than matched, the counts differ accordingly
- The summary line accounts for filtering by group, status, and any other applicable filters

# Technical Solution

TODO

# Execution Plan

TODO 