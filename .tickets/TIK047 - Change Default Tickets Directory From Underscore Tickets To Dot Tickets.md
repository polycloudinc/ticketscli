---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK047
aliases:
- TIK047
name: Change Default Tickets Directory From Underscore Tickets To Dot Tickets
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank: null
ticket_created: '2026-06-20T06:44:30Z'
ticket_updated: '2026-06-20T06:58:53Z'
ticket_completed: '2026-06-20T06:58:48Z'
---
# Introduction

Change the default tickets directory from `_tickets` to `.tickets`. The dot-prefixed convention aligns with common tools (`.git`, `.github`, `.vscode`) and keeps the directory hidden in file listings. The `_tickets` naming predates this convention.

# Requirements

- All hardcoded `_tickets` defaults in `tickets.sh` must change to `.tickets`
- `tickets.sh` must perform a pre-check for every subcommand that accepts `--tickets-dir` / `-d`, resolving the actual directory to use as follows:
  - If `--tickets-dir` / `-d` is explicitly provided, use that path (no resolution logic)
  - If `.tickets/` exists and `_tickets/` does not, use `.tickets/` (silent)
  - If `_tickets/` exists and `.tickets/` does not, use `_tickets/` and emit a warning to stderr: `Warning: _tickets is deprecated. Rename the directory to .tickets to migrate.`
  - If both `.tickets/` and `_tickets/` exist, emit an error to stderr and exit: `Error: both .tickets and _tickets directories exist. Remove one or use --tickets-dir.`
  - If neither exists, default to `.tickets/` (the subcommand will create it if needed, e.g., `init`)
- The `tickets init` subcommand must create `.tickets/` instead of `_tickets/`
- Agent skills referencing the `_tickets/` directory must be updated to `.tickets/`
- Documentation (`Tickets System.md`) must reflect the new default and the compatibility behavior
- The `.devcontainer/Dockerfile` and any CI configs must not hardcode the directory name

# Technical Solution

## Directory resolution

Implement a `resolve_tickets_dir()` function in `tickets.sh` that encapsulates the compatibility logic. The function takes the flag-provided directory (or empty string if not provided) and returns the resolved path:

```bash
resolve_tickets_dir() {
  local flag_dir="$1"

  if [[ -n "$flag_dir" ]]; then
    echo "$flag_dir"
    return 0
  fi

  local has_dot=0 has_under=0
  [[ -d ".tickets" ]] && has_dot=1
  [[ -d "_tickets" ]] && has_under=1

  if [[ $has_dot -eq 1 && $has_under -eq 1 ]]; then
    echo "Error: both .tickets and _tickets directories exist. Remove one or use --tickets-dir." >&2
    exit 1
  fi

  if [[ $has_dot -eq 1 ]]; then
    echo ".tickets"
  elif [[ $has_under -eq 1 ]]; then
    echo "Warning: _tickets is deprecated. Rename the directory to .tickets to migrate." >&2
    echo "_tickets"
  else
    echo ".tickets"
  fi
}
```

Each subcommand replaces its `local tickets_dir="_tickets"` with:
```bash
local tickets_dir
tickets_dir=$(resolve_tickets_dir "")
```
And the flag parsing replaces the ticket_dir default with `local tickets_dir=""` (leaving resolution to `resolve_tickets_dir`).

## Other changes

All remaining `_tickets` defaults (e.g., `local tickets_dir="_tickets"`) change to `.tickets` where they appear outside flag parsing (e.g., `cmd_rank` when it calls `normalize_ranks`). Agent skills under `.apm/skills/` and `.agents/skills/` must update all About sections and instruction text from `_tickets/` to `.tickets/`. `Tickets System.md` must be updated accordingly.

# Execution Plan

## Phase 1: tickets.sh Directory Resolution

- [x] Add `resolve_tickets_dir()` function to `tickets.sh` implementing the compatibility logic (flag override, both-exist error, legacy warning, `.tickets` default)
- [x] Update `cmd_list` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `cmd_create` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `cmd_validate` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `cmd_transition` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `cmd_rank` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `cmd_rank_up`, `cmd_rank_down`, `cmd_rank_first`, `cmd_rank_last` to use `resolve_tickets_dir`
- [x] Update `cmd_statistics_snapshot` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `cmd_init` to call `resolve_tickets_dir` instead of `local tickets_dir="_tickets"`
- [x] Update `normalize_ranks()` and any other helpers that take a `tickets_dir` parameter
- [x] Verify: `--tickets-dir` / `-d` flag continues to override the resolved default

## Phase 2: Agent Skills

- [x] Update `.apm/skills/tickets-create/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Update `.apm/skills/tickets-execution-plan/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Update `.apm/skills/tickets-init/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Update `.apm/skills/tickets-list/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Update `.apm/skills/tickets-rank/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Update `.apm/skills/tickets-review/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Update `.apm/skills/tickets-transition/SKILL.md` — replace `_tickets/` with `.tickets/`
- [x] Sync `.agents/skills/` from `.apm/skills/`

## Phase 3: Documentation, Migration, and Verification

- [x] Update `Tickets System.md` — replace all `_tickets` references with `.tickets`
- [x] Rename the repository's `_tickets/` directory to `.tickets/`
- [x] Verify `tickets list` works with `.tickets/`
- [x] Verify `tickets list` with `_tickets/` legacy directory (create a temp `_tickets/` with a settings.yaml, confirm warning appears)
- [x] Verify error when both `.tickets/` and `_tickets/` exist
- [x] Verify `--tickets-dir` overrides to an arbitrary path
- [x] Verify `tickets init` creates `.tickets/` by default
- [x] Verify `tickets validate --all`, `tickets create`, `tickets transition`, `tickets rank`, `tickets statistics snapshot` all work