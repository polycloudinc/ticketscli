---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK035
aliases:
  - TIK035
name: Add Tickets Statistics Snapshot Subcommand
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-14T07:25:22Z
ticket_updated: 2026-06-14T14:47:01Z
ticket_completed: 2026-06-14T14:47:01Z
---
# Introduction

Add a `tickets statistics snapshot` subcommand that computes metrics from the current ticket corpus and appends the results as a timestamped record to a `_tickets/statistics.yaml` time-series file, enabling trend analysis and project health tracking over time.

# Requirements

### Metrics Computed

Running `tickets statistics snapshot` computes the following metrics from the current ticket corpus:

- **Total tickets** — count of all `.md` files in `_tickets/` (excluding settings.yaml and statistics.yaml).
- **Count by status** — breakdown for each status: Backlog, Ready, In Progress, Complete, Duplicate, Won't Fix.
- **Todo count** — tickets in Backlog, Ready, or In Progress.
- **Done count** — tickets in Complete, Duplicate, or Won't Fix.

The computed metrics are both printed to stdout and appended as a timestamped record to `_tickets/statistics.yaml`.

If the tickets directory is empty (no `.md` files), all counts are zero — a snapshot is still recorded.

### Stdout Format

Metrics are printed to stdout as key-value pairs:

```
ts: 2026-06-14T07:30:00Z
total: 34
status:
  backlog: 12
  ready: 5
  inprogress: 1
  complete: 14
  duplicate: 1
  wontfix: 1
groups:
  todo: 18
  done: 16
```

### Snapshot Recording

Each invocation appends a snapshot record to `_tickets/statistics.yaml`:

```yaml
statistics:
  - ts: 2026-06-14T07:30:00Z
    total: 34
    status:
      backlog: 12
      ready: 5
      inprogress: 1
      complete: 14
      duplicate: 1
      wontfix: 1
    groups:
      todo: 18
      done: 16
```

### CLI Interface

```
Usage: tickets statistics snapshot [options]

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```

- `statistics` is the subcommand; `snapshot` is its only sub-subcommand (two-level structure allows future expansion).
- Running `tickets statistics` without a sub-subcommand prints the statistics usage and exits.
- The file is append-only; existing records are never modified.
- If `_tickets/statistics.yaml` does not exist, it is created.

### File Conventions

- The statistics file is `_tickets/statistics.yaml`, containing a root `statistics` key whose value is a list of snapshot objects.
- Each snapshot is keyed by a `ts` field in ISO 8601 UTC format.
- The `list` and `validate` subcommands ignore this file (it does not match the ticket filename convention).

# Technical Solution

Add a `cmd_statistics_snapshot()` function to `tickets.sh` following the patterns of existing subcommand functions (see `cmd_list` at line 532, `cmd_create` at line 709).

### Changes to `tickets.sh`

1. **Help text** — Add `statistics_usage()` function with the CLI usage defined above.
2. **Function** — Implement `cmd_statistics_snapshot()`:
   - Parse `-d`/`--tickets-dir` and `-h`/`--help` flags.
   - Glob all `.md` files in the tickets directory, excluding `settings.yaml` and `statistics.yaml`.
   - For each ticket file, extract the YAML frontmatter between `---` delimiters with `sed`, then parse `ticket_status` with `yq eval '.ticket_status' -` (same pattern used by `cmd_validate`).
   - Tally counts: total, one per status, todo (backlog + ready + inprogress), done (complete + duplicate + wontfix).
   - Generate current UTC timestamp with `date -u +"%Y-%m-%dT%H:%M:%SZ"`.
   - Print metrics to stdout as `key: value` pairs (with `ts` for the timestamp field).
   - If `statistics.yaml` does not exist, create it with a `statistics:` root key containing an empty list, then append the snapshot object to that list.
   - If `statistics.yaml` exists, append the snapshot object to the existing `statistics` list using `yq`.
   - If no `.md` files are found in the tickets directory, output all-zero counts and record the snapshot.
3. **Dispatch** — Add a `statistics` case in the top-level `case` statement (after `rank` at line 1323) with an inner `case` dispatching `snapshot` to `cmd_statistics_snapshot`.
4. **Usage** — Add `statistics snapshot` to the main `usage()` help text.

# Execution Plan

- [ ] Add `statistics_usage()` help text function
- [ ] Implement `cmd_statistics_snapshot()` function
- [ ] Add `statistics` dispatch case with `snapshot` sub-subcommand
- [ ] Update `usage()` to list `statistics snapshot` 