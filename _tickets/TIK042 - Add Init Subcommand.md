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
- Copy the built-in ticket template to `_templates/Ticket.md` if it does not already exist; locate the template from `als-tickets-template/als-tickets-template-main/Ticket.md` via a reference in the CLI module's `package.json`
- Keep `als-tickets-template` and `als-tickets-cli` as separate modules; add a reference to the template module's `Ticket.md` in the CLI module's `package.json`
- Support a `-d` / `--tickets-dir` flag to specify an alternate tickets directory (defaults to `_tickets`)
- Report each item created or skipped to stdout

# Technical Solution

- Add a `cmd_init` function to `tickets.sh` following the existing subcommand pattern: argument parsing loop with `-d`/`--tickets-dir`, `--code-prefix`, and `-h`/`--help`, then directory and file creation logic
- Resolve the ticket template by reading a template path reference from the CLI module's `package.json`, falling back to repo-root search for `_templates/Ticket.md` (as `cmd_create` does)
- Resolve the `--code-prefix` value: use the flag value if provided (after validation), otherwise read from stdin with a prompt; validate it matches `^[A-Za-z]{3,4}$` and uppercase it
- Add `init` dispatch case to the main `case` block and add `init_usage` function
- Add `init` to the top-level `usage()` listing

# Execution Plan

## Phase 1 — Add template reference to CLI package.json

- [ ] Add a field to `als-tickets-cli/als-tickets-cli-main/package.json` referencing the path to `als-tickets-template/als-tickets-template-main/Ticket.md`
- [ ] Verify `cmd_init` can read the reference from `package.json` to locate the template

## Phase 2 — Implement `cmd_init` in tickets.sh

- [ ] Add `init_usage()` function alongside the other `*_usage` functions
- [ ] Implement `cmd_init()` with: argument parsing (`-d`, `--code-prefix`, `-h`), halt-if-initialized check, code prefix resolution (flag or interactive prompt with validation), directory creation, template copy, `settings.yaml` and `statistics.yaml` creation, and output reporting
- [ ] Add `init)` case to the main dispatch `case` block
- [ ] Add `init` entry to the top-level `usage()` listing
- [ ] Sync changes to `als-tickets-cli/als-tickets-cli-main/tickets.sh`
- [ ] Verify: run `bash tickets.sh init` in a temp directory and confirm all files and directories are created

## Phase 3 — Integration verification

- [ ] Verify `bash tickets.sh init --code-prefix FOO` works without interactive prompt
- [ ] Verify interactive prompt accepts valid input and rejects invalid input
- [ ] Verify `bash tickets.sh init` halts when `_tickets/settings.yaml` already exists
- [ ] Verify `bash tickets.sh init -d custom` creates everything under `custom/`