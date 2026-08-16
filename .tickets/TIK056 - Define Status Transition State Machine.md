---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK056
ticket_name: Define Status Transition State Machine
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 13
ticket_created: '2026-08-15T17:02:06Z'
ticket_updated: '2026-08-16T16:48:45Z'
ticket_completed: null
---
# Introduction

The `transition` subcommand currently accepts any status as a target, with no notion of which transitions are legal — a ticket can jump straight from Backlog to Complete, for example. Define an explicit state machine describing which status-to-status transitions are allowed, so status changes are governed by a sane, enforceable workflow.

# Requirements

- The set of legal transitions between statuses must be defined explicitly and documented, starting from the existing statuses (Backlog, Ready, In Progress, Complete, Duplicate, Won't Fix)
- The default state machine must be sensible but not overly restrictive: forward progress (Backlog to Ready to In Progress to Complete) and reasonable fallbacks must be legal, terminal statuses (Complete, Duplicate, Won't Fix) must be shown as end states, and reopening a terminal ticket must be an explicit, legal transition
- `transition` must reject a requested status change that is not a legal transition with a clear error message naming the legal target statuses from the current state
- Everyday flows must not be blocked — e.g. moving a ticket backwards or sideways within the workflow must remain possible unless the state machine says otherwise
- The state machine must remain compatible with customized status sets (see TIK055) so projects can define their own transitions alongside their own statuses
- `validate` must not flag a ticket merely for having a status reachable via legal transitions; enforcement lives in `transition`
- Documentation (`Tickets.md`) and agent skills must describe the state machine and its defaults

# Technical Solution

TODO

# Execution Plan

TODO 
