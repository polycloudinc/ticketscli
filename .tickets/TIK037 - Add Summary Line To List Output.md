---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK037
aliases:
- TIK037
name: Add Summary Line To List Output
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-06-14T08:15:10Z'
ticket_updated: '2026-06-14T08:32:03Z'
ticket_completed: '2026-06-14T08:32:02Z'
---
# Introduction

Add a summary line to the tabular output of the `list` subcommand that displays the number of tickets shown and the total number of tickets found, so users can see when the `--limit` flag has restricted the displayed results.

# Requirements

- A summary line appears after the table output showing "Showing X of Y tickets"
- When no `--limit` flag is used, the "showing" count equals the "total" count
- When `--limit` is used and fewer tickets are displayed than matched, the counts differ accordingly
- The summary line accounts for filtering by group, status, and any other applicable filters

# Technical Solution

## Approach

Count `total` during the existing filter-iteration loop (lines 636-667 of `cmd_list()`). After the table body, write displayed rows to a second tempfile (or use `tee` with `wc -l`) to obtain the `shown` count, then print the summary line and clean up.

## Implementation Steps

1. **Declare counters and a second tempfile at the top of the function** (alongside the existing `tmpfile`):
   - `total=0`
   - `shown_tmpfile=$(mktemp)` — captures only the rows actually displayed.

2. **Increment `total` inside the per-file filter loop** whenever a ticket passes all filters (after line 658, before line 660).

3. **Replace the existing `sort | head | while` pipeline** (line 679) so that the displayed rows are simultaneously:
   - printed to stdout (for the user),
   - written to `shown_tmpfile` (for counting afterwards).

   Implementation:
   ```bash
   sort -t$'\t' -k1 -n "$tmpfile" | head -n "${limit:-999999}" | tee "$shown_tmpfile" | while IFS=$'\t' read -r rank_val number subject status; do
     ...
   done
   ```

4. **After the table, compute `shown`**:
   ```bash
   local shown
   shown=$(wc -l < "$shown_tmpfile")
   echo "Showing $shown of $total tickets"
   ```

5. **Clean up both tempfiles:**
   ```bash
   rm -f "$tmpfile" "$shown_tmpfile"
   ```

## Edge Cases

- When no `--limit` is used, `shown` equals `total`.
- When `--limit` is specified and fewer tickets match than the limit (e.g. `-l 10` but only 4 match), `shown` equals `total`.
- When `--limit` is specified and more tickets match than the limit, `shown` < `total`.
- `total` reflects only tickets that passed the group/status filter; tickets excluded by the `case "$filter"` block (lines 648-658) are not counted.
- If `total` is 0 (no tickets match the filter), the summary "Showing 0 of 0 tickets" is still printed.

# Execution Plan

## Implement summary line in cmd_list()

- [x] Declare `total=0` and `shown_tmpfile=$(mktemp)` alongside the existing `tmpfile` at the top of `cmd_list()`
- [x] Increment `total` by 1 inside the per-file iteration loop after a ticket passes all filter checks (after line 658)
- [x] Insert `tee "$shown_tmpfile"` into the `sort | head | while` pipeline so displayed rows are captured for counting
- [x] After the table output, compute `shown` via `wc -l < "$shown_tmpfile"` and print `"Showing $shown of $total tickets"`
- [x] Update the `rm` cleanup at the end to also remove `$shown_tmpfile`

## Verify

- [x] Run `bash tickets.sh list` with no filters and confirm `shown` equals `total`
- [x] Run `bash tickets.sh list -l 3` and confirm `shown` is 3 and `total` is higher
- [x] Run `bash tickets.sh list --group todo` and confirm both counts reflect only non-done tickets
- [x] Run `bash tickets.sh list --group backlog` and confirm `shown` equals `total` (no limit, counts match)
- [x] Run `bash tickets.sh list -l 100` and confirm `shown` equals `total` when limit exceeds match count
