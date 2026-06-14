---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK004
aliases:
  - TIK004
name: Kanban Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 4
ticket_created: 2026-06-09T06:11:51Z
ticket_updated: 2026-06-14T08:32:03Z
ticket_completed:
---
# Introduction

Add a `kanban` subcommand to the `tickets` CLI that displays tickets organized by status in a kanban-style column layout.

# Requirements

- `tickets kanban` displays tickets grouped into columns by status: Backlog, Ready, In Progress, and Complete. Duplicate and Won't Fix tickets are excluded from the kanban display.
- Each column shows a header with the status name and ticket count, followed by the ticket codes and subjects for tickets in that status.
- Empty columns (no tickets with that status) are still displayed with a count of 0.
- Supports the `--tickets-dir` / `-d` option to specify a custom tickets directory (same as `list`).
- Output must remain readable on a standard 80-column terminal. Column widths are computed dynamically from `tput cols`, allocated evenly across all four status columns (Backlog, Ready, In Progress, Complete) regardless of whether any are empty. Subject text is truncated to fit column width with `...` appended when shortened.

# Technical Solution

Add a `cmd_kanban` function in `tickets.sh` and wire it into the top-level subcommand dispatch. Read all tickets into an associative array keyed by status. Compute column widths based on terminal width and the four status columns. Render each column vertically with the ticket codes and truncated subjects stacked underneath. Disable column gap padding for the last column to avoid trailing whitespace issues.

# Execution Plan

- [ ] Add `kanban` to the top-level `usage` output and subcommand `case` dispatch.
- [ ] Implement `cmd_kanban` that reads all tickets and groups them by status.
- [ ] Compute column layout based on `tput cols` and four status columns (Backlog, Ready, In Progress, Complete), allocating width evenly.
- [ ] Render each status column with header, count, and ticket entries using computed widths.
- [ ] Support `--tickets-dir` / `-d` option in `kanban` (same semantics as `list`).
- [ ] Verify `tickets kanban` displays all status columns with correct groupings.
- [ ] Verify `tickets kanban` includes empty status columns with a count of 0.
- [ ] Verify `tickets kanban -d /path/to/tickets` reads from the custom directory.
- [ ] Verify output fits within 80 columns for a realistic set of tickets.
