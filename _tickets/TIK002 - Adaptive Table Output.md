---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK002
aliases:
  - TIK002
name: Adaptive Table Output
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-09T06:11:51Z
ticket_updated: 2026-06-14T06:20:21Z
ticket_completed: 2026-06-14T06:20:21Z
---
# Introduction

Make the `tickets list` table output adapt to the available terminal width instead of using hardcoded column widths.

# Requirements

- The table output must fit within the current terminal width (as reported by `tput cols` or `$COLUMNS`).
- Column widths must be allocated proportionally: the Code column gets a fixed minimum (8 chars), the Rank column gets a fixed minimum (5 chars), the Status column gets a fixed minimum (12 chars), and the Subject column absorbs the remaining space.
- Subject text must be truncated to fit the Subject column width (with `...` appended when truncated).
- On very narrow terminals (below a minimum threshold, e.g. 40 chars), output should degrade gracefully — columns are not squeezed below their minimums; the subject column retains its clamped minimum width and line overflow is tolerated rather than breaking table structure.

# Technical Solution

Replace the hardcoded `printf` width values in `cmd_list` with computed widths based on `tput cols`. Compute `subject_width` as `cols - code_width(8) - rank_width(5) - status_width(12) - spacing(num_columns - 1)` — i.e. `cols - 8 - 5 - 12 - 3 = cols - 28`. Clamp `subject_width` to a reasonable minimum (e.g. `10`). Use dynamic width values in the header, separator, and data `printf` calls. Truncate the subject with `...` appended when it exceeds `subject_width` (use bash substring: `subject_width - 3` for the visible portion then append `...`). Truncation must happen in the first pass (for loop, before writing to tmpfile) since the tmpfile is used only for sorting and printing.

# Execution Plan

- [x] Read the terminal width via `tput cols` with a fallback to `80`.
- [x] Compute `subject_width` as `cols - code_width(8) - rank_width(5) - status_width(12) - (num_columns - 1)`.
- [x] Clamp `subject_width` to a minimum of `10`.
- [x] Replace hardcoded subject truncation (`[[ ${#subject} -gt 41 ]] && subject="${subject:0:38}..."`) with dynamic truncation based on computed `subject_width`: `[[ ${#subject} -gt $subject_width ]] && subject="${subject:0:$((subject_width - 3))}..."`.
- [x] Update header `printf` call to use computed widths.
- [x] Update separator `printf` call to use computed widths (aligned with column widths).
- [x] Update data row `printf` call to use computed widths.
- [x] Verify output at default 80-column width looks correct.
- [x] Verify output adapts correctly when terminal is resized (e.g. `COLUMNS=120 tickets list`).
- [x] Verify output on a narrow terminal (e.g. `COLUMNS=50 tickets list`) truncates subject gracefully.
- [x] Verify output on an extremely narrow terminal (e.g. `COLUMNS=30 tickets list`) does not produce broken formatting.
