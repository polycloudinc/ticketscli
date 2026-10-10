---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK066
ticket_name: Extend Tickets CLI To Cover Architecture Design Records
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 21
ticket_created: null
ticket_updated: '2026-10-10T02:48:01Z'
ticket_completed: null
---
# Introduction

The tickets CLI currently manages only tickets. This work extends the CLI to also manage Architecture Design Records (ADRs), enabling tracking of architectural decisions alongside work items within the same `.tickets/` directory.

# Requirements

- ADRs must be distinguishable from tickets by a dedicated front matter field (e.g., `kind: adr`) while reusing the existing `.tickets/` directory structure
- The create subcommand must support an `--adr` flag (or similar mechanism) to create ADRs with appropriate front matter and a scaffolded ADR body template
- The list subcommand must support filtering by `kind` to show only tickets, only ADRs, or both
- The validate subcommand must accept ADR documents with their own schema rules (distinct from tickets) while still enforcing baseline front matter correctness
- Existing ticket subcommands (transition, rank, kanban, statistics, roadmap) must handle ADRs gracefully, either by excluding them or by offering applicable ADR-specific behavior where it makes sense
- ADRs must support a status workflow (e.g., proposed, accepted, deprecated, superseded) separate from ticket statuses

# Technical Solution

TODO

# Execution Plan

TODO