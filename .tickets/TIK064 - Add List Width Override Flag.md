---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK064
ticket_name: Add List Width Override Flag
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 20
ticket_created: "2026-08-16T07:14:54Z"
ticket_updated: "2026-08-16T07:14:54Z"
ticket_completed:
---
# Introduction

The `list` subcommand derives its table width from `tput cols` at runtime, which is unreliable for piped output and gives users no way to force a specific width. This ticket adds a way to explicitly override the viewport width used by `tickets list`.

# Requirements

- Provide a command-line option to `tickets list` that explicitly sets the table width, overriding the terminal-derived value (`tput cols` / `$COLUMNS`)
- The explicit width must be honored even when stdout is piped or redirected (where `tput cols` may return an unrelated or failing value)
- The option must validate that the supplied width is a positive integer, erroring out clearly otherwise (consistent with `-l/--limit` behavior)
- The existing default behavior (terminal-derived width, subject truncation with `...`, 10-char minimum subject width) must remain unchanged when the option is not supplied
- Update the `list` usage text to document the new option

# Technical Solution

TODO

# Execution Plan

TODO 
