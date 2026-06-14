---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK035
aliases:
  - TIK035
name: Add Tickets Stats Subcommand With Time Series Recording
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 11
ticket_created: 2026-06-14T07:25:22Z
ticket_updated: 2026-06-14T07:25:22Z
ticket_completed:
---
# Introduction

Add a `tickets stats` subcommand that computes live metrics from the current ticket corpus and appends the results as a timestamped record to a `_tickets/statistics.yaml` time-series file, enabling trend analysis and project health tracking over time.

# Requirements

### Live Metrics Output
Running `tickets stats` (with no recording) prints a summary to stdout:

- **Total tickets** — count of all `.md` files in `_tickets/` (excluding settings.yaml and statistics.yaml).
- **Count by status** — breakdown for each of the six statuses: Backlog, Ready, In Progress, Complete, Duplicate, Won't Fix.
- **Count by priority** — breakdown for Critical, High, Medium, Low.
- **Active tickets** — count of non-done tickets (Backlog + Ready + In Progress).
- **Completion ratio** — done count / total count as a percentage.
- **Oldest active ticket** — code and name of the active ticket with the earliest `ticket_created` date.
- **Average rank gap** — average difference between consecutive ranks (detects rank fragmentation).

### Time Series Recording
`tickets stats --record` (or `-r`) appends a snapshot record to `_tickets/statistics.yaml`:

```yaml
- timestamp: 2026-06-14T07:30:00Z
  total: 34
  backlog: 12
  ready: 5
  in_progress: 1
  complete: 14
  duplicate: 1
  wontfix: 1
  critical: 0
  high: 3
  medium: 28
  low: 3
  active: 18
  completion_pct: 47.1
  avg_active_age_days: 4.2
```

### History Viewing
`tickets stats --history` (or `-H`) reads `statistics.yaml` and prints a table of recorded snapshots with key columns:

```
Timestamp            Total  Backlog  Ready  InProg  Complete  Dup  Wontfix  Active  Done%
2026-06-10T12:00:00Z    28       10      3       1        12    1        1      14   50.0
2026-06-12T12:00:00Z    30       11      4       1        12    1        1      16   46.7
2026-06-14T07:30:00Z    34       12      5       1        14    1        1      18   47.1
```

### CLI Interface
```
Usage: tickets stats [options]

Options:
  -r, --record         Compute stats and append to _tickets/statistics.yaml
  -H, --history        Display all recorded statistics snapshots as a table
  -d, --tickets-dir    Path to tickets directory (default: _tickets)
  -h, --help           Show this help message
```

- With no flags, prints the live summary only (no recording).
- `--record` prints the summary AND appends to the file.
- `--history` reads and displays existing records (no new recording).
- `--record` and `--history` are mutually exclusive.

### File Conventions
- The statistics file is `_tickets/statistics.yaml`, a YAML list of snapshot objects.
- Each snapshot is keyed by a `timestamp` field in ISO 8601 UTC format.
- The file is append-only; existing records are never modified.
- The `list` and `validate` subcommands ignore this file (it does not match the ticket filename convention).
- If the file does not exist, `--record` creates it; `--history` reports no records.

# Technical Solution

TODO

# Execution Plan

TODO 