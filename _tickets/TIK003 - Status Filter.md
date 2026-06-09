---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK003
aliases:
  - TIK003
name: Status Filter
subjects: cli
ticket_status: "[[Backlog]]"
ticket_priority: Medium
---
# Introduction

Add a `--status` / `-s` filter to the `tickets list` subcommand allowing the user to filter tickets by an explicit status value instead of being limited to the three grouped filter flags.

# Requirements

- `tickets list --status <value>` (short form `-s`) filters tickets to only those whose `ticket_status` matches the given value.
- The value is matched against the plain status name (e.g. `Ready`, not `[[Ready]]`). The wiki-link wrapping is stripped before comparison, consistent with existing behavior.
- The `--status` filter is mutually exclusive with `--backlog`, `--active`, and `--done`. Only one filter may be specified.
- If an unrecognized status value is passed, the command prints an error listing valid statuses and exits non-zero.

# Technical Solution

Extend the argument parser in `cmd_list` to accept `--status` / `-s` with a required value argument. When set, set `filter` to `--status` and store the value. In the filter case block, add a `--status` branch that compares `$status` against the stored value. Validate the value against the known set: `Backlog`, `Ready`, `In Progress`, `Complete`, `Duplicate`, `Won't Fix`.

# Execution Plan

- [ ] Add `--status` / `-s` to the `list` option parser with a required value argument.
- [ ] Validate the provided status value against the known set; print error and exit if invalid.
- [ ] Enforce mutual exclusivity with `--backlog`, `--active`, `--done`.
- [ ] Add a `--status` branch in the filter `case` block that matches `$status` against the provided value.
- [ ] Update `list_usage` help text to document the new option.
- [ ] Verify `tickets list --status Ready` lists only Ready tickets.
- [ ] Verify `tickets list -s Backlog` lists only Backlog tickets.
- [ ] Verify `tickets list --status Ready --active` exits with a mutual exclusivity error.
- [ ] Verify `tickets list --status Bogus` exits with an error listing valid statuses.
