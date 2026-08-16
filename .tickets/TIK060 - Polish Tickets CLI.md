---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK060
aliases:
  - TIK060
name: Polish Tickets CLI
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 17
ticket_created: 2026-08-16T03:04:59Z
ticket_updated: 2026-08-16T03:04:59Z
ticket_completed:
---
# Introduction

The tickets CLI works but has accumulated rough edges — stale help text quoting the old `_tickets` default, inconsistent help formatting and flag conventions across subcommands, and minor behavioral inconsistencies. Polish the CLI so it is consistent, accurate, and pleasant to use, without changing the working behavior of the system.

# Requirements

- All help and usage text must be accurate: every subcommand's `default:` line must state the real default (`.tickets`, not `_tickets`), and descriptions must match actual behavior; `create -n` help must refer to the option as `name`, not `subject`
- Help output must be consistently formatted across all subcommands — aligned option columns, consistent wording, and no trailing whitespace or stray punctuation
- Flag conventions must be consistent: a given option should use the same short and long flag spelling everywhere it appears (e.g. tickets-dir), with any legacy spellings noted or dropped
- `tickets init` must support `-p` as a short form of `--code-prefix`, documented in its help output
- Error messages must be consistent in tone and format (same prefix, capitalization, and layout) across subcommands
- The top-level usage must accurately reflect the subcommand set and their relationship (e.g. `rank` variants)
- The automated test suite must gain coverage asserting the polished help output (accurate defaults, exit 0 on `--help`) so regressions are caught
- No functional behavior of any subcommand may change as a result of this polishing (unless the change is a bug fix required by the accuracy requirements above)

# Technical Solution

TODO

# Execution Plan

TODO 