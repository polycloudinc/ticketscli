---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK042
aliases:
  - TIK042
name: Add Init Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 9
ticket_created: 2026-06-15T11:44:30Z
ticket_updated: 2026-06-15T11:44:30Z
ticket_completed:
---
# Introduction

Add an `init` subcommand to the tickets CLI that bootstraps a new project with the required directory structure, ticket template, and default settings, making the tickets system self-bootstrapping.

# Requirements

- Create the `_tickets/` directory if it does not exist
- Halt with an error if the tickets directory has already been initialized (i.e. `settings.yaml` already exists)
- Support a `--code-prefix` flag to set the ticket code prefix; apply the same validation as the interactive prompt (3-4 char alpha, uppercased)
- When `--code-prefix` is not supplied, interactively prompt for a value; validate the input is a 3 or 4 character alphabetic string and uppercase it for storage; no default value is shown in the prompt
- Create `_tickets/settings.yaml` with the resolved code prefix if it does not already exist
- Create `_tickets/statistics.yaml` with `statistics: []` if it does not already exist
- Create the `_templates/` directory if it does not exist
- Copy the built-in ticket template to `_templates/Ticket.md` if it does not already exist; locate the template relative to the script (from the npm package when running via npx, or from the repo root `_templates/Ticket.md` when running via `bash tickets.sh`)
- Bundle `_templates/Ticket.md` in the npm package by updating `als-tickets-cli/als-tickets-cli-main/package.json` `files` field
- Support a `-d` / `--tickets-dir` flag to specify an alternate tickets directory (defaults to `_tickets`)
- Report each item created or skipped to stdout

# Technical Solution

TODO

# Execution Plan

- Add a `cmd_init` function to `tickets.sh` following the existing subcommand pattern: argument parsing loop with `-d`/`--tickets-dir`, `--code-prefix`, and `-h`/`--help`, then directory and file creation logic
- Resolve the ticket template by checking `$script_dir/_templates/Ticket.md` first (bundled in npm package), falling back to repo-root search (as `cmd_create` does)
- Resolve the `--code-prefix` value: use the flag value if provided (after validation), otherwise read from stdin with a prompt; validate it matches `^[A-Za-z]{3,4}$` and uppercase it
- Add `_templates/Ticket.md` to the npm package `files` array in `package.json` and copy it into `als-tickets-cli/als-tickets-cli-main/_templates/`
- Add `init` dispatch case to the main `case` block and add `init_usage` function
- Add `init` to the top-level `usage()` listing