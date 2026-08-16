---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK059
aliases:
  - TIK059
name: Drop Underscore Tickets Directory Resolution
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 16
ticket_created: 2026-08-16T01:54:17Z
ticket_updated: 2026-08-16T01:54:17Z
ticket_completed:
---
# Introduction

The tickets CLI still recognizes the legacy `_tickets/` directory — auto-detecting it with a deprecation warning and even supporting the now-removed both-exist error path. Now that `.tickets` is the established default and per-project configuration is being added (TIK058), drop `_tickets/` resolution entirely so the tickets directory behavior is simple and predictable.

# Requirements

- `resolve_tickets_dir()` must no longer detect, warn about, or fall back to a `_tickets/` directory; the "both `.tickets` and `_tickets` exist" error path must be removed
- When only a `_tickets/` directory is present, the CLI must not silently resolve it — it should emit a clear message directing the user to rename it (`mv _tickets .tickets`) so legacy projects are not silently orphaned
- All help text in `tickets.sh` must state the default as `.tickets`, not `_tickets`
- The resolution order documented and enforced must be: `--tickets-dir` flag, then configured setting (TIK058), then `.tickets` default
- The test suite must be updated: `tc010_tickets_dir_resolution` drops the both-exist and `_tickets`-with-warning cases and covers the new only-`_tickets`-present behavior, and other cases must use `.tickets` only
- `Tickets System.md` must remove the `_tickets`-related resolution table rows and migration note (or replace them with the rename guidance above)
- Live skill/content references to `_tickets/` (e.g. `SKILL-ABOUT.md` in the skill component) must be updated to `.tickets`
- No code path may reference `_tickets` as a default or fallback after this change

# Technical Solution

TODO

# Execution Plan

TODO 