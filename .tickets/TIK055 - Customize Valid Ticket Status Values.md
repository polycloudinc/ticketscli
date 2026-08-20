---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK055
ticket_name: Customize Valid Ticket Status Values
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 12
ticket_created: '2026-08-15T17:01:26Z'
ticket_updated: '2026-08-16T16:48:45Z'
ticket_completed: null
---
# Introduction

The set of valid ticket statuses is currently hardcoded in the CLI (Backlog, Ready, In Progress, Complete, Duplicate, Won't Fix). Allow projects to customize which statuses are valid so teams can adapt the workflow to their own process.

# Requirements

- A project must be able to define its own set of valid statuses (names, order, and which statuses count as done/open) through configuration, with the current six statuses remaining the default
- `validate` must accept any ticket_status value listed in the configured statuses and reject statuses outside the list
- `transition` must restrict target statuses to the configured list and accept those statuses as input
- `list` groups (`backlog`, `todo`, `done`) and `kanban` columns must respect the configured statuses, with done-group semantics derived from the configured done statuses
- `statistics` and the `rank` subcommand must continue to work correctly with a customized status set
- The configured status order must determine display order in `list` and `kanban` output
- Documentation (`Tickets.md`) and agent skills must describe how to customize statuses

# Technical Solution

TODO

# Execution Plan

TODO 
