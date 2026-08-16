---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK039
ticket_name: Statistics Chart Subcommand
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 10
ticket_created: '2026-06-14T14:55:07Z'
ticket_updated: '2026-08-16T16:48:45Z'
ticket_completed: null
---
# Introduction

Add a `statistics chart` sub-subcommand that reads time-series snapshot data from `statistics.yaml` and renders an ASCII chart in the terminal, giving users a visual trend view of ticket counts over time without leaving the CLI.

# Requirements

- Reads time-series data from `statistics.yaml` as its data source
- Renders an ASCII chart directly in the terminal using only built-in shell tooling (no external chart libraries)
- Supports rendering a chart for the total ticket count trend across all snapshots
- Supports rendering a status breakdown chart (stacked or overlaid series: backlog, ready, in-progress, complete, etc.)
- Supports rendering a group summary chart (todo vs done)
- Adapts to terminal width for readable output regardless of window size
- Handles missing or empty `statistics.yaml` gracefully with a clear message
- Inherits `-d`/`--tickets-dir` from the parent `statistics` subcommand
- Inherits `-h`/`--help` for usage information
- Follows the existing two-level `statistics <sub>` dispatch pattern alongside `snapshot`

# Technical Solution

TODO

# Execution Plan

TODO
