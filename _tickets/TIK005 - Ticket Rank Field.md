---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK005
aliases:
  - TIK005
name: Ticket Rank Field
ticket_status: "[[Backlog]]"
ticket_priority: Medium
---
# Introduction

Add a `ticket_rank` field to the ticket frontmatter that holds an integer rank. Rank 1 represents the highest priority ticket, rank 2 the second highest, and so on up to as many tickets as the project holds. Also add `rank up`, `rank down`, `rank first`, and `rank last` subcommands that adjust ticket priority by swapping positions or moving tickets to the top or bottom of the ranking.

# Requirements

- The ticket template must include a `ticket_rank` field in the YAML frontmatter, defaulting to no value.
- All existing tickets must be updated to include `ticket_rank` with a sequential integer value unique across the project.
- The `tickets list` output must be sorted ascending by `ticket_rank` when the field is present. Tickets without a rank are sorted last.
- A `rank` subcommand must be added to assign or reassign ranks to all tickets, numbering them sequentially starting at 1 in the order they appear in the `_tickets/` directory (sorted by filename). The command rewrites each ticket file, updating the `ticket_rank` value in the frontmatter.
- A `rank up` subcommand must be added that promotes a ticket's priority. It accepts a `--ticket` / `-t` option with the ticket code to promote. The subcommand decrements the ticket's rank by 1 and increments the rank of the ticket that currently holds that rank by 1, effectively swapping their ranks. If the ticket is already at rank 1, the command prints a message indicating the ticket is already at the highest rank and exits without changes.
- A `rank down` subcommand must be added that demotes a ticket's priority. It accepts a `--ticket` / `-t` option with the ticket code to demote. The subcommand increments the ticket's rank by 1 and decrements the rank of the ticket that currently holds that rank by 1, effectively swapping their ranks. If the ticket is already at the highest rank in the project, the command prints a message indicating the ticket is already at the lowest rank and exits without changes.
- A `rank first` subcommand must be added that moves a ticket to rank 1. It accepts a `--ticket` / `-t` option with the ticket code to promote. The specified ticket is set to rank 1, and every ticket that previously held ranks 1 through (old_rank - 1) has its rank incremented by 1, shifting them down. If the ticket is already at rank 1, the command prints a message and exits without changes.
- A `rank last` subcommand must be added that moves a ticket to the lowest rank. It accepts a `--ticket` / `-t` option with the ticket code to demote. The specified ticket is set to the highest rank number N (where N is the total number of tickets), and every ticket that previously held ranks (old_rank + 1) through N has its rank decremented by 1, shifting them up. If the ticket is already at the lowest rank, the command prints a message and exits without changes.

# Technical Solution

Add `ticket_rank:` to the Ticket.md template. In `tickets.sh`, create a `cmd_rank` function that reads all ticket filenames in sorted order, opens each file, and uses `sed` to set `ticket_rank:` on the line following the existing field (or updates it if present). Create `cmd_rank_up` and `cmd_rank_down` functions that parse `--ticket` / `-t`, reads all tickets and their ranks, swaps the rank of the specified ticket with the ticket at `rank - 1` (up) or `rank + 1` (down), and writes both files. Create `cmd_rank_first` that sets the target ticket's rank to 1 and increments all tickets ranked 1 through (old_rank - 1) by 1. Create `cmd_rank_last` that sets the target ticket's rank to N and decrements all tickets ranked (old_rank + 1) through N by 1. In `cmd_list`, parse `ticket_rank` from frontmatter and sort tickets by rank before rendering. Tickets with no rank or a non-integer rank sort after all ranked tickets.

# Execution Plan

- [ ] Add `ticket_rank:` field to the ticket template (`Ticket.md`).
- [ ] Add `ticket_rank:` field to all existing ticket files with unique ranks matching the execution plan.
- [ ] Implement `cmd_rank` subcommand that rewrites ticket files with sequential ranks.
- [ ] Implement `cmd_rank_up` subcommand with `--ticket` / `-t` option to swap ranks upward.
- [ ] Implement `cmd_rank_down` subcommand with `--ticket` / `-t` option to swap ranks downward.
- [ ] Implement `cmd_rank_first` subcommand with `--ticket` / `-t` option to move a ticket to rank 1.
- [ ] Implement `cmd_rank_last` subcommand with `--ticket` / `-t` option to move a ticket to the lowest rank.
- [ ] Wire `cmd_rank`, `cmd_rank_up`, `cmd_rank_down`, `cmd_rank_first`, and `cmd_rank_last` into the top-level subcommand dispatch and usage output.
- [ ] Update `cmd_list` to sort tickets by `ticket_rank` ascending before rendering.
- [ ] Verify `tickets rank` assigns sequential ranks to all tickets in `_tickets/`.
- [ ] Verify `tickets rank up --ticket TIK003` decrements TIK003's rank and increments the displaced ticket's rank.
- [ ] Verify `tickets rank up --ticket TIK001` (already rank 1) prints message and exits without changes.
- [ ] Verify `tickets rank down --ticket TIK003` increments TIK003's rank and decrements the displaced ticket's rank.
- [ ] Verify `tickets rank down --ticket TIK005` (already lowest rank) prints message and exits without changes.
- [ ] Verify `tickets rank first --ticket TIK004` sets TIK004 to rank 1 and shifts intermediate tickets down.
- [ ] Verify `tickets rank first --ticket TIK001` (already rank 1) prints message and exits without changes.
- [ ] Verify `tickets rank last --ticket TIK002` sets TIK002 to the lowest rank and shifts intermediate tickets up.
- [ ] Verify `tickets rank last --ticket TIK005` (already lowest rank) prints message and exits without changes.
- [ ] Verify `tickets list` output is sorted by rank.
