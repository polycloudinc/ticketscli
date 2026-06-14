---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK017
aliases:
  - TIK017
name: Validate Subcommand with Schema Validation
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
---

# Introduction

Add a `validate` subcommand to `tickets.sh` that validates a ticket's YAML front matter against the standard ticket schema, reporting any deviations.

# Requirements

- A new `validate` subcommand must be added to `tickets.sh` that accepts a ticket code as an argument (e.g. `tickets validate TIK001`).
- The subcommand supports `-t`/`--tickets-dir` to specify a non-default tickets directory.
- The schema source of truth is the canonical ticket template at `als-tickets-template/als-tickets-template-main/Ticket.md`. The `validate` command extracts its front matter keys with `yq` to determine the set of mandatory fields. **All fields in the template are mandatory** — every field listed in the template's front matter must be present in each ticket.
- Validation checks three categories of deviations:
  1. **Missing fields** — fields in the template but absent from the target ticket.
  2. **Unknown fields** — fields in the target ticket but not in the template.
  3. **Invalid values** — fields whose values violate hardcoded constraint rules in `tickets.sh`.
- Value constraint rules are hardcoded directly in `tickets.sh` (not in an external schema file):
  | Field             | Constraint                                                       |
  |-------------------|------------------------------------------------------------------|
  | `template`        | Must be `"[[Ticket]]"`                                          |
  | `kind`            | Must be `ticket`                                                 |
  | `code`            | Must match `TIK\d{3}`                                           |
  | `name`            | Must be non-empty                                                |
  | `aliases`         | Must contain exactly one entry matching the `code` value          |
  | `ticket_status`   | Must be one of: `[[Backlog]]`, `[[Ready]]`, `[[In Progress]]`, `[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]` |
  | `ticket_priority` | Must be one of: `Low`, `Medium`, `High`, `Critical`              |
  | `tags`            | No value constraint (any content accepted)                       |
- `yq` is a prerequisite. The dev container Dockerfile must install `yq` so it is available on next container rebuild.
- Validation report format: each deviation is printed to stderr as a bullet with the field name and description of the issue.
- The subcommand exits with code 0 if no deviations are found, and code 1 if one or more deviations are detected.
- Help text (`-h`/`--help`) must be available for the `validate` subcommand.

# Technical Solution

Use `yq` to parse YAML front matter. The canonical ticket template at `als-tickets-template/als-tickets-template-main/Ticket.md` serves as the source of truth for the mandatory field set. `cmd_validate()` uses `yq` to extract the template's front matter keys, then compares the target ticket's front matter against that key set. Field-specific value constraints are hardcoded in the function body.

**Validation steps:**

1. Extract the template's front matter keys with `yq` — this is the mandatory field set.
2. Extract the target ticket's front matter keys and values with `yq`.
3. Report any missing fields (fields in the template but absent from the target ticket).
4. Report any unknown fields (fields in the target ticket but not in the template).
5. For each constrained field, validate its value against the hardcoded rules (`template`, `kind`, `code`, `name`, `aliases`, `ticket_status`, `ticket_priority`).

The `tickets` dispatcher in `tickets.sh` is extended to route the `validate` subcommand to `cmd_validate()`. All value constraints live in `tickets.sh` — no external schema file needed.

# Execution Plan

### Setup

- [x] Add `yq` installation to `.devcontainer/Dockerfile` so it is available on next container rebuild.
- [x] Install `yq` in the current dev environment.

### Implementation

- [x] Implement `cmd_validate()` in `tickets.sh` — locate ticket file, extract front matter with `yq`.
- [x] Extract template field keys from `als-tickets-template/als-tickets-template-main/Ticket.md` as the reference schema.
- [x] Implement missing-field and unknown-field checks by diffing ticket keys against template keys.
- [x] Implement hardcoded value constraint validations for: `template`, `kind`, `code`, `name`, `aliases`, `ticket_status`, `ticket_priority`.
- [x] Implement deviation reporting to stderr with exit code 1 on violations.
- [x] Wire the `validate` subcommand into the top-level dispatcher with usage/help text.

### Verification

- [x] Verify `tickets list` shows TIK017 after creating it.
