---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK054
ticket_name: Revise Ticket Front Matter
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 4
ticket_created: "2026-08-15T16:56:25Z"
ticket_updated: "2026-08-16T15:44:30Z"
ticket_completed:
---
# Introduction

The ticket front matter has accumulated Obsidian-style conventions — wiki-link values, `template`/`tags`/`aliases` properties — that add noise and coupling to a Plain-Text-focused ticket system. Revise the front matter to a minimal, versioned, flat schema using plain values so tickets are simple, portable, and free of Obsidian-specific conventions, and add a `migrate` subcommand that converts existing tickets from the current unversioned schema to the versioned schema.

# Requirements

- The front matter schema must contain only the minimal set of fields the CLI actually needs (identity, status, priority, rank, timestamps), with no decorative or tool-specific properties
- Obsidian-specific properties (`template`, `tags`, `aliases`) must be removed from the template and from all tickets; the `kind` key with value `ticket` is retained
- The first key in the front matter must be `api` with the value `polycloudinc/ticketscli/v1`, identifying the schema version
- The `code` key must be renamed to `ticket_code` and the `name` key to `ticket_name` for consistency with the other `ticket_*` fields
- The `aliases` key must be dropped from the template and from all tickets
- Wiki-link values must be replaced with plain lowercase codes with no spaces (e.g. `[[Won't Fix]]` → `wontfix`, `[[In Progress]]` → `inprogress`) everywhere
- A new `migrate` subcommand must convert tickets from the current unversioned schema to the target versioned schema
- `tickets migrate` must accept a `--target`/`-t` switch to select the target schema version
- The migration implementation must be organized as a version-pair function named `migrate_unversioned_to_v1`
- All existing CLI subcommands (`create`, `list`, `transition`, `rank`, `validate`, `statistics`, `kanban`) must read, write, and validate the versioned schema
- Any CLI subcommand (other than `migrate`) that reads or writes a ticket must halt with an error when the ticket is not declared as `api: polycloudinc/ticketscli/v1`
- All existing tickets must be migrated to the versioned schema without losing status, priority, rank, or timestamp data
- Documentation (`Tickets.md`) and agent skills must describe the versioned schema

# Technical Solution

## Versioned schema (v1)

Canonical front matter for every ticket after migration:

```yaml
---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK001
ticket_name: List Subcommand
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 1
ticket_created: 2026-08-16T00:00:00Z
ticket_updated: 2026-08-16T00:00:00Z
ticket_completed:
---
```

All status codes are plain lowercase alphanumeric scalars (safe unquoted in YAML):

| Wiki-link value | v1 code |
| --- | --- |
| `[[Backlog]]` | `backlog` |
| `[[Ready]]` | `ready` |
| `[[In Progress]]` | `inprogress` |
| `[[Complete]]` | `complete` |
| `[[Duplicate]]` | `duplicate` |
| `[[Won't Fix]]` | `wontfix` |

## `tickets migrate` subcommand

Usage: `tickets migrate [--target|-t <version>] [--tickets-dir|-d <dir>]`

- `--target`/`-t` selects the target schema version; `v1` is the only supported target and is the default. The `api` value is derived from the target: `polycloudinc/ticketscli/<version>`.
- Operates on all tickets in the tickets directory, skipping `.gitkeep`.
- The implementation dispatches to a version-pair function. This ticket adds `migrate_unversioned_to_v1 <file>` which converts a single ticket from the current unversioned schema (no `api` key) to `v1`:
  - Inserts `api: polycloudinc/ticketscli/v1` as the first front matter key
  - Deletes the `template`, `tags`, and `aliases` keys; retains `kind` with value `ticket`
  - Renames `code` to `ticket_code` and `name` to `ticket_name`
  - Remaps `ticket_status` via the mapping table above
  - Preserves `ticket_code`, `ticket_name`, `ticket_priority`, `ticket_rank`, `ticket_created`, `ticket_updated`, and `ticket_completed` unchanged
  - Does not modify any timestamps
- Tickets that already carry the `api` key for the target version are skipped with a notice (idempotent).
- Tickets that carry an `api` key for an unknown version are reported as errors and left untouched.
- Unknown `--target` values are rejected with a usage error.

## CLI alignment to v1

- `Ticket.md` template drops the `template`, `tags`, and `aliases` keys and keeps `kind: ticket`: `api` first, then `kind`, `ticket_code`, `ticket_name`, and the six `ticket_*` fields
- `cmd_create` emits the v1 front matter (`api` first, `ticket_code`, `ticket_name`, `ticket_status: backlog`)
- `cmd_transition` writes lowercase status codes; the completed-status logic (clear rank, set `ticket_completed`) is unchanged
- `validate_one` requires `api` as the first/leading key with value `polycloudinc/ticketscli/v1`, treats `template`/`tags`/`aliases` as unknown fields, expects `kind: ticket`, and accepts the lowercase status codes; priority/rank/timestamp checks are unchanged
- `cmd_list` and the statistics/kanban paths drop the `sed 's/^\[\[//; s/\]\]$//'` strip; a display-name map (code → `In Progress` etc.) may be kept for output readability
- A `require_api_v1 <file>` guard helper is added and invoked by every command that reads or writes a ticket (create, list, transition, rank, validate, statistics, kanban): it extracts the `api` key and halts with an error naming the offending file when the key is missing or not `polycloudinc/ticketscli/v1`. `tickets migrate` is exempt since it exists to convert unversioned tickets.
- `yz.py` needs no changes (generic YAML operations)
- Tests: fixtures and cases updated to v1; a new migrate test case covers mapping correctness, idempotency, and `--target`/`-t` handling; a guard test case covers commands halting on unversioned tickets

# Execution Plan

## Phase 1 — Schema definition

### Tasks

- [x] Update `Ticket.md` template: drop the `template` and `tags` keys and the `aliases` key, keep `kind: ticket`, rename `code` to `ticket_code` and `name` to `ticket_name`; add `api: polycloudinc/ticketscli/v1` as the first key
- [x] Update `Tickets.md` (template block and status section) with the v1 schema and the status code mapping table

### Verification Steps

- [x] Confirm the template block in `Tickets.md` shows `api` as the first key, contains no `template`/`tags`/`aliases` keys, keeps `kind: ticket`, and uses `ticket_code`/`ticket_name`

## Phase 2 — Migrate subcommand

### Tasks

- [x] Add `cmd_migrate` with `--target`/`-t` and `--tickets-dir`/`-d` options, usage text, and top-level dispatch wiring
- [x] Implement `migrate_unversioned_to_v1`: insert `api` first, delete the `template` and `tags` keys and the `aliases` key, keep `kind` with value `ticket`, rename `code` to `ticket_code` and `name` to `ticket_name`, remap `ticket_status`, preserve all other data
- [x] Add skip/error handling: already at target version (skip with notice), unknown `api` version (error, untouched), unknown `--target` (usage error)

### Verification Steps

- [x] Run `tickets migrate -t v1 -d <scratch copy of .tickets>` and confirm output tickets have `api` as the first key, no Obsidian fields, renamed `ticket_code`/`ticket_name`, remapped status codes, and preserved ranks/timestamps; already-migrated tickets are skipped

## Phase 3 — CLI alignment and repo migration

### Tasks

- [x] Update `cmd_create` to emit the v1 front matter (`api` first, `ticket_code`, `ticket_name`, `ticket_status: backlog`)
- [x] Update `cmd_transition` to write lowercase status codes
- [x] Update `validate_one`: require `api` as first key with value `polycloudinc/ticketscli/v1`, flag `template`/`tags`/`aliases` as unknown fields, expect `kind: ticket`, accept lowercase status codes, expect `ticket_code` and `ticket_name` instead of `code` and `name`
- [x] Update `cmd_list` and statistics/kanban paths to read status codes directly
- [x] Add the `require_api_v1` guard to all ticket-reading/writing commands (create, list, transition, rank, validate, statistics, kanban); halt with an error naming the file when a ticket is not declared `api: polycloudinc/ticketscli/v1`; `migrate` is exempt
- [x] Migrate all tickets in `.tickets/` with `tickets migrate -t v1`

### Verification Steps

- [x] `tickets validate --all` reports zero deviations on the migrated repo
- [x] `tickets create` produces a v1 ticket, and `tickets transition`/`list`/`statistics` work on v1 tickets
- [x] A command run against a ticket lacking the v1 `api` key halts with an error and leaves the ticket untouched

## Phase 4 — Tests and agent skills

### Tasks

- [x] Update test fixtures to the v1 schema
- [x] Update test cases (including create/validate/transition greps for `[[Backlog]]` and `aliases`) and add migrate and api-guard test cases
- [x] Update skills in `.apm/skills/` (About sections, `tickets-create` steps, `tickets-transition` mapping table) and re-sync to `.agents/skills/`

### Verification Steps

- [x] Run `./test.sh` and confirm the full test suite passes
