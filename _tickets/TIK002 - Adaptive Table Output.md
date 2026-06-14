---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK002
aliases:
  - TIK002
name: Adaptive Table Output
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 1
---
# Introduction

Make the `tickets list` table output adapt to the available terminal width instead of using hardcoded column widths.

# Requirements

- The table output must fit within the current terminal width (as reported by `tput cols` or `$COLUMNS`).
- Column widths must be allocated proportionally: the Code column gets a fixed minimum (8 chars), the Status column gets a fixed minimum (12 chars), and the Subject column absorbs the remaining space.
- Subject text must be truncated to fit the Subject column width (with `...` appended when truncated).
- On very narrow terminals (below a minimum threshold, e.g. 40 chars), output should degrade gracefully — columns are not squeezed below their minimums.

# Technical Solution

Replace the hardcoded `printf` width values in `cmd_list` with computed widths based on `tput cols`. Compute `subject_width` as `$(tput cols) - 8 - 12 - 3` (accounting for column spacing). Clamp `subject_width` to a reasonable minimum (e.g. `10`). Use dynamic width values in the header and data `printf` calls.

# Execution Plan

- [ ] Read the terminal width via `tput cols` with a fallback to `80`.
- [ ] Compute `subject_width` as `cols - code_width - status_width - (columns - 1)` to account for padding between columns.
- [ ] Clamp `subject_width` to a minimum of `10`.
- [ ] Update header `printf` calls to use computed widths.
- [ ] Update data row `printf` call to use computed widths.
- [ ] Verify output at default 80-column width looks correct.
- [ ] Verify output adapts correctly when terminal is resized (e.g. `COLUMNS=120 tickets list`).
- [ ] Verify output on a narrow terminal (e.g. `COLUMNS=50 tickets list`) truncates subject gracefully.
- [ ] Verify output on an extremely narrow terminal (e.g. `COLUMNS=30 tickets list`) does not produce broken formatting.
