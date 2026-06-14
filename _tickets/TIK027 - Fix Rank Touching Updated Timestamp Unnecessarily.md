---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK027
aliases:
  - TIK027
name: Fix Rank Touching Updated Timestamp Unnecessarily
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-14T06:36:31Z
ticket_updated: 2026-06-14T07:10:31Z
ticket_completed: 2026-06-14T07:10:31Z
---
# Introduction

The `rank` command updates the `ticket_updated` timestamp on every ticket it processes, even when only the `ticket_rank` value remains unchanged. The timestamp should only be modified when a ticket's fields actually change.

# Requirements

- Running `tickets rank` on a set of tickets where none of their `ticket_rank` values change must not modify the `ticket_updated` field in any ticket file.
- The `ticket_updated` timestamp must continue to update when `ticket_rank` or any other frontmatter field is actually modified.

# Technical Solution

Before modifying `ticket_rank`, compare the existing value against the new value. Only call `touch_ticket_updated` when they differ.

1. **`normalize_ranks` done-ticket branch:** Read the existing rank with `get_ticket_rank` before clearing it; only touch if the old rank was non-empty.
2. **`normalize_ranks` active-ticket loop:** Capture the old rank from the tempfile (first column) and compare against the new sequential rank.
3. **`set_ticket_rank`:** Read the existing rank with `get_ticket_rank` before writing the new one; only touch if they differ.

# Execution Plan

## Phase 1: Fix `normalize_ranks` (bare `rank` / normalization)

- [x] In the done-ticket branch (line ~143), read the existing rank value before clearing it; only call `touch_ticket_updated` if the old rank was non-empty (i.e., the field actually changed).
- [x] In the active-ticket re-rank loop (line ~163), read the existing rank value before assigning `$new_rank`; only call `touch_ticket_updated` if the new rank differs from the old rank.

## Phase 2: Fix `set_ticket_rank` (rank mutation subcommands)

- [x] In `set_ticket_rank` (line ~187), read the current rank before applying the new one; only call `touch_ticket_updated` if the new rank differs from the old rank.

## Phase 3: Verify

- [x] Run `bash tickets.sh rank` on an already-normalized set of tickets and confirm no `ticket_updated` timestamps are modified.
- [x] Run each rank mutation subcommand (`rank up`, `rank down`, `rank first`, `rank last`) with a no-op movement (e.g., moving the first ticket up) and confirm `ticket_updated` is not touched.
- [x] Run a genuine rank mutation (e.g., demoting a ticket) and confirm `ticket_updated` is updated as expected.
- [x] Run `bash tickets.sh validate` to confirm no frontmatter regressions. 