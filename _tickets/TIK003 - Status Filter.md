---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK003
aliases:
  - TIK003
name: Status Filter
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-09T06:11:51Z
ticket_updated: 2026-06-14T05:45:20Z
ticket_completed: 2026-06-14T05:45:20Z
---
# Introduction

Add a `--status` / `-s` filter to the `tickets list` subcommand allowing the user to filter tickets by an explicit status value instead of being limited to the three grouped filter flags.

# Requirements

- `tickets list --status <value>` (short form `-s`) filters tickets to only those whose `ticket_status` matches the given value.
- The value is matched against the plain status name (e.g. `Ready`, not `[[Ready]]`). The wiki-link wrapping is stripped before comparison, consistent with existing behavior.
- The `--status` filter is mutually exclusive with `--group` (i.e. `--group` and `--status` cannot both be specified). Only one filter may be specified.
- The status value is matched case-insensitively (e.g. `ready` and `Ready` both work). Multi-word statuses like `In Progress` must be quoted on the command line (`tickets list --status "In Progress"`).
- If an unrecognized status value is passed, the command prints an error listing valid statuses and exits non-zero.

# Technical Solution

Extend the argument parser in `cmd_list` (`tickets.sh:31–58`) to accept `--status` / `-s` with a required value argument. When set, set `$filter` to a special token (e.g. `status:<value>`) to distinguish it from `--group`. In the filter `case` block (`tickets.sh:75–79`), add a `status:*)` branch that extracts and compares `$status` against the stored value. Validate the value against the known set: `Backlog`, `Ready`, `In Progress`, `Complete`, `Duplicate`, `Won't Fix`. Both copies of the script must be updated: `./tickets.sh` (root) and `./als-tickets-cli/als-tickets-cli-main/tickets.sh`.

# Execution Plan

- [x] Add `--status` / `-s` to the `list` option parser `while`/`case` block (`tickets.sh:31–58`) with a required value argument.
- [x] Validate the provided status value (case-insensitive) against the known set; print error listing valid statuses and exit if invalid.
- [x] Enforce mutual exclusivity with `--group` (`tickets.sh:40`); reject `--status` if `$filter` is already set.
- [x] Store the validated value into `$filter` using a distinguishable token (e.g. `status:ready`).
- [x] Add a `status:*)` branch in the filter `case` block (`tickets.sh:75–79`) that extracts the stored value and matches `$status` against it.
- [x] Update `list_usage` help text (`tickets.sh:16–25`) to document the new `-s, --status <value>` option.
- [x] Apply identical changes to `./als-tickets-cli/als-tickets-cli-main/tickets.sh`.
- [x] Verify `tickets list --status Ready` lists only Ready tickets.
- [x] Verify `tickets list -s Backlog` lists only Backlog tickets.
- [x] Verify `tickets list -s in\ progress` lists only In Progress tickets (via quoted `"in progress"`).
- [x] Verify `tickets list --status Ready --group active` exits with a mutual exclusivity error.
- [x] Verify `tickets list --status Bogus` exits with an error listing valid statuses.
