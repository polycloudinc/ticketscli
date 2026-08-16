---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK045
ticket_name: Add Roadmap Subcommand
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 11
ticket_created: '2026-06-16T16:09:43Z'
ticket_updated: '2026-08-16T16:48:45Z'
ticket_completed: null
---
# Introduction

Add a `roadmap` subcommand to the tickets CLI that generates a cohesive Roadmap markdown document summarizing the current state of all tickets grouped by status and priority.

# Requirements

- A `roadmap` subcommand is available via the tickets CLI (`tickets.sh roadmap` or `npx @aleisium/tickets roadmap`).
- The subcommand generates a single Roadmap.md document in the repository root.
- The generated document groups tickets by status (`[[Backlog]]`, `[[Ready]]`, `[[In Progress]]`, `[[Complete]]`), with each group sorted by priority (highest first).
- Each ticket entry in the roadmap includes its code, name, priority, and rank.
- The output is a valid, well-formatted Markdown document suitable for sharing with stakeholders.
- The generated document includes a timestamp indicating when it was last generated.

# Technical Solution

TODO

# Execution Plan

TODO 
