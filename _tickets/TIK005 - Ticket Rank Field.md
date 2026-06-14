---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK005
aliases:
  - TIK005
name: Ticket Rank Field
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-09T06:11:51Z
---
# Introduction

Add a `ticket_rank` field to the ticket frontmatter that holds an integer rank. Rank 1 represents the highest priority ticket, rank 2 the second highest, and so on up to as many tickets as the project holds. Also add `rank up`, `rank down`, `rank first`, and `rank last` subcommands that adjust ticket priority by swapping positions or moving tickets to the top or bottom of the ranking.

# Requirements

- The ticket template must include a `ticket_rank` field in the YAML frontmatter, defaulting to no value. This must be updated in both locations: `als-tickets-template/als-tickets-template-main/Ticket.md` (the source template package) and `_templates/Ticket.md` (the template used by the CLI at runtime).
- All existing tickets must be updated to include `ticket_rank` with a sequential integer value unique across the project.
- The `tickets list` output must be sorted ascending by `ticket_rank` when the field is present. Tickets without a rank are sorted last.
- A `rank` subcommand must be added that normalizes ranks across all tickets, closing gaps by reassigning contiguous 1..N integers in current rank-sorted order while preserving the existing relative ordering. On first run (all tickets unranked), tickets are ranked in filename sort order since all unranked tickets tiebreak by filename. The command rewrites each ticket file, updating the `ticket_rank` value in the frontmatter.
- When `tickets create` generates a new ticket, it must automatically assign `ticket_rank` as `max_existing_rank + 1`, placing the new ticket at the bottom of the ranked list. If no tickets exist yet, the rank is 1.
- `tickets validate` must check that `ticket_rank` is present and holds an integer value. Tickets missing the field or with a non-integer value must be reported as validation errors.
- All rank mutation subcommands (`rank up`, `rank down`, `rank first`, `rank last`) must first normalize ranks across all tickets to remove any gaps before performing their operation. Normalization reassigns ranks as contiguous integers 1..N in current rank-sorted order, preserving the existing relative ordering. The rank mutation is then applied against the normalized ranks.
- A `rank up` subcommand must be added that promotes a ticket's priority. It accepts a `--ticket` / `-t` option with the ticket code to promote. After normalization, the subcommand decrements the ticket's rank by 1 and increments the rank of the ticket that currently holds that rank by 1, effectively swapping their ranks. If the ticket is already at rank 1, the command prints a message indicating the ticket is already at the highest priority and exits without changes.
- A `rank down` subcommand must be added that demotes a ticket's priority. It accepts a `--ticket` / `-t` option with the ticket code to demote. After normalization, the subcommand increments the ticket's rank by 1 and decrements the rank of the ticket that currently holds that rank by 1, effectively swapping their ranks. If the ticket is already at the highest rank number (i.e. N, where N is the total number of ranked tickets), the command prints a message indicating the ticket is already at the lowest priority and exits without changes.
- A `rank first` subcommand must be added that moves a ticket to rank 1. It accepts a `--ticket` / `-t` option with the ticket code to promote. After normalization, the specified ticket is set to rank 1, and every ticket that previously held ranks 1 through (old_rank - 1) has its rank incremented by 1, shifting them down. If the ticket is already at rank 1, the command prints a message and exits without changes.
- A `rank last` subcommand must be added that moves a ticket to the lowest rank. It accepts a `--ticket` / `-t` option with the ticket code to demote. After normalization, the specified ticket is set to the highest rank number N (where N is the total number of tickets), and every ticket that previously held ranks (old_rank + 1) through N has its rank decremented by 1, shifting them up. If the ticket is already at the lowest rank, the command prints a message and exits without changes.

# Technical Solution

Add `ticket_rank:` to the ticket template in both locations: `als-tickets-template/als-tickets-template-main/Ticket.md` and `_templates/Ticket.md`. In `tickets.sh`, implement a shared `normalize_ranks` function that reads all tickets, sorts them by current `ticket_rank` (with unranked tickets at the end, tiebroken by filename), and rewrites each file with contiguous ranks 1..N. All rank commands (`cmd_rank`, `cmd_rank_up`, `cmd_rank_down`, `cmd_rank_first`, `cmd_rank_last`) call `normalize_ranks` first, then the mutation commands apply their operation on the normalized ranks. Use `sed` to update `ticket_rank:` in each file. In `cmd_create`, compute the new ticket's rank as `max_existing_rank + 1` and emit the `ticket_rank:` line in the generated frontmatter. In `cmd_list`, parse `ticket_rank` from frontmatter and sort tickets by rank before rendering. Tickets with no rank or a non-integer rank sort after all ranked tickets. In `cmd_validate`, add a check that `ticket_rank` exists and is an integer value; report deviations as errors.

# Execution Plan

## Phase 1: Template & Ticket Updates

- [x] Add `ticket_rank:` field to both ticket template locations (`als-tickets-template/als-tickets-template-main/Ticket.md` and `_templates/Ticket.md`).
- [x] Add `ticket_rank:` field to all existing ticket files with sequential integer values.

## Phase 2: Normalization & List Sorting

- [x] Implement `normalize_ranks` shared function that rewrites ticket files with contiguous ranks 1..N in current rank-sorted order (unranked tickets tiebreak by filename).
- [x] Implement `cmd_rank` subcommand that calls `normalize_ranks` and reports counts.
- [x] Wire `cmd_rank` into the top-level subcommand dispatch and usage output.
- [x] Update `cmd_list` to extract `ticket_rank` from frontmatter and sort tickets ascending by rank before rendering (unranked/non-integer sort last).
- [x] Verify `tickets rank` assigns contiguous ranks 1..N to all tickets in `_tickets/`.
- [x] Verify `tickets list` output is sorted by rank.

## Phase 3: Rank Mutation Subcommands

- [x] Implement `cmd_rank_up` subcommand — parse `--ticket` / `-t`, call `normalize_ranks`, then swap the target ticket's rank with the ticket at `rank - 1`.
- [x] Implement `cmd_rank_down` subcommand — parse `--ticket` / `-t`, call `normalize_ranks`, then swap the target ticket's rank with the ticket at `rank + 1`.
- [x] Implement `cmd_rank_first` subcommand — parse `--ticket` / `-t`, call `normalize_ranks`, then set target to rank 1 and increment ranks 1 through `old_rank - 1` by 1.
- [x] Implement `cmd_rank_last` subcommand — parse `--ticket` / `-t`, call `normalize_ranks`, then set target to rank N and decrement ranks `old_rank + 1` through N by 1.
- [x] Wire `cmd_rank_up`, `cmd_rank_down`, `cmd_rank_first`, and `cmd_rank_last` into the top-level subcommand dispatch and usage output.
- [x] Verify `tickets rank up --ticket TIK003` normalizes then decrements TIK003's rank and increments the displaced ticket's rank.
- [x] Verify `tickets rank up --ticket TIK001` (already rank 1) prints message and exits without changes.
- [x] Verify `tickets rank down --ticket TIK003` normalizes then increments TIK003's rank and decrements the displaced ticket's rank.
- [x] Verify `tickets rank down --ticket TIK005` (already highest rank number) prints message and exits without changes.
- [x] Verify `tickets rank first --ticket TIK004` normalizes then sets TIK004 to rank 1 and shifts intermediate tickets down.
- [x] Verify `tickets rank first --ticket TIK001` (already rank 1) prints message and exits without changes.
- [x] Verify `tickets rank last --ticket TIK002` normalizes then sets TIK002 to the lowest rank and shifts intermediate tickets up.
- [x] Verify `tickets rank last --ticket TIK005` (already lowest rank) prints message and exits without changes.
- [x] Verify no gaps remain in ranks after any `rank up`, `rank down`, `rank first`, or `rank last` command.

## Phase 4: Create & Validate Integration

- [x] Update `cmd_create` to emit `ticket_rank` as `max_existing_rank + 1` in generated frontmatter (or 1 if no tickets exist).
- [x] Update `cmd_validate` to check that `ticket_rank` is present and holds an integer value.
- [x] Verify `tickets create --name "New Feature"` assigns rank `max_existing_rank + 1` to the new ticket.
- [x] Verify `tickets validate` reports errors for tickets missing `ticket_rank` or with a non-integer rank value.
