---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK001
aliases:
  - TIK001
name: List Subcommand
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
---
# Introduction

Add a `list` subcommand to the `tickets` CLI so that listing tickets is done via `tickets list` instead of the bare `tickets` command.

# Requirements

- The CLI must support a `list` subcommand that lists tickets from the `_tickets/` directory by default.
- A `--tickets-dir` / `-t` option must allow overriding the default `_tickets/` path (e.g. `tickets list -t /path/to/tickets`).
- The existing filter flags (`--backlog`/`-b`, `--active`/`-a`, `--done`/`-d`) must remain available as options under `list`, with the same semantics and mutual exclusivity.
- Running `tickets` with no subcommand must print usage/help information rather than silently listing all tickets.

# Technical Solution

Convert the single-level `tickets` script into a subcommand-aware entry point. The top-level `tickets` command dispatches to the `list` subcommand handler, which contains the current filtering and rendering logic. Introduce an explicit `-h`/`--help` flag for usage output. Add a `--tickets-dir` / `-t` option that overrides the internal `TICKETS_DIR` variable. The `list` subcommand handler retains the same frontmatter-parsing, status-filtering, and formatted-output behavior as the current implementation.

# Execution Plan

- [x] Verify the current `tickets.sh` behavior with no arguments (lists all tickets) and with each filter flag.
- [x] Refactor `tickets.sh` to parse a subcommand argument before filter flags.
- [x] Add `--tickets-dir` / `-t` option parsing, defaulting to `_tickets`.
- [x] Handle unknown subcommands with an error message and usage output.
- [x] Handle no subcommand by printing usage/help information.
- [x] Verify `tickets list` (no filter, default dir) lists all tickets.
- [x] Verify `tickets list --active` lists only Ready and In Progress tickets.
- [x] Verify `tickets list --done` lists only Done and Won't Fix tickets.
- [x] Verify `tickets list --backlog` lists only Backlog tickets.
- [x] Verify `tickets list -t /tmp/mytickets` reads from the specified directory and lists tickets.
- [x] Verify that specifying more than one filter flag under `list` produces the expected error.
- [x] Verify the tickets module can still be installed and invoked via `npx @aleisium/tickets list`.
