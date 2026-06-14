---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK034
aliases:
  - TIK034
name: Formalize Ticket Priority Field And Workflow
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 9
ticket_created: 2026-06-14T07:24:21Z
ticket_updated: 2026-06-14T08:32:03Z
ticket_completed:
---
# Introduction

Define the canonical values, semantics, and workflow rules for the `ticket_priority` field, add a CLI subcommand to change priority, and create an agent skill so users and agents can manage ticket priority through natural language and the command line.

# Requirements

### Schema Formalization
- The four legal `ticket_priority` values are explicitly documented with definitions:
  - `Critical` — Must be addressed immediately; blocks other work.
  - `High` — Important and should be worked soon, ahead of normal-priority items.
  - `Medium` — Default priority for new tickets; normal workflow.
  - `Low` — Nice-to-have; can be deferred indefinitely.
- The `validate` subcommand constraint (already enforced) is documented in `Tickets.md` alongside the other field constraints.

### CLI Subcommand
- A `tickets priority <code> <level>` subcommand sets the `ticket_priority` field on a ticket.
- Input is case-insensitive and fuzzy-matched (e.g., `crit` resolves to `Critical`, `med` to `Medium`).
- The command touches `ticket_updated` and reports the change.
- Short flag variants are supported: `tickets priority -t <code> -p <level>`.

### Agent Skill
- A `prioritize-ticket` skill is created under `.apm/skills/prioritize-ticket/`.
- It maps natural-language phrases ("mark TIK005 as critical", "lower TIK003 to low", "set priority high on TIK012") to the CLI subcommand.
- It handles fuzzy status-to-priority mapping (e.g., "urgent" → Critical, "important" → High, "normal" → Medium, "minor" → Low).

### Workflow Rules
- New tickets default to `Medium` (no change from current behavior).
- Changing priority does not affect rank or status.
- Priority is preserved across status transitions (no implicit changes).
- The `list` subcommand output optionally displays priority when a `--priority` or `-p` flag is passed, or adds a priority column alongside the existing four columns.

# Technical Solution

TODO

# Execution Plan

TODO 