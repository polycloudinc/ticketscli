---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK063
ticket_name: Json Output Option For List And Other Commands
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 18
ticket_created: '2026-08-16T06:37:06Z'
ticket_updated: '2026-08-16T16:48:46Z'
ticket_completed: null
---
# Introduction

The tickets CLI is currently human-readable only, producing formatted tables and text. Give subcommands such as `list` and `statistics` an option to emit structured JSON so output can be consumed by scripts and other tooling.

# Requirements

- `list` must support a `--json` flag that outputs the same ticket data shown in table form as valid JSON without losing any information
- The JSON output for `list` must include each ticket's full set of front matter fields (code, name, status, priority, rank, timestamps, tags) mapped to field keys consistent with the front matter field names
- Summary output that `list` normally prints must be suppressed when `--json` is used so the stdout stream is pure JSON
- Other output-producing subcommands (e.g. `statistics snapshot` and `statistics chart`) must also support a `--json` flag with the same flag name and JSON output conventions
- Human-readable output must remain the default when `--json` is not specified, and the existing human output must not change
- JSON output must be parseable by standard JSON tools (e.g. `jq`) and must handle the empty-tickets case by emitting `[]`
- Help text for each affected subcommand must document the `--json` flag

# Technical Solution

TODO

# Execution Plan

TODO 
