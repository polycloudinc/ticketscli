---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK058
aliases:
- TIK058
name: Configure Tickets Directory Per Project
ticket_status: '[[Backlog]]'
ticket_priority: Medium
ticket_rank: 15
ticket_created: '2026-08-16T01:29:49Z'
ticket_updated: '2026-08-16T01:46:47Z'
ticket_completed: null
---
# Introduction

The tickets directory is currently resolved implicitly (`.tickets`/`_tickets` detection) or per-invocation via `--tickets-dir`. Because tools like Obsidian deliberately hide dot-prefixed directories, teams may want tickets stored in a visible directory. Add a per-project configuration setting so the tickets directory name is fixed in one place rather than passed on every command.

# Requirements

- A project must be able to set the tickets directory name (e.g. `Tickets`) in its configuration (`settings.yaml`), replacing the default `.tickets` for all subcommands
- The configured directory must be respected by every subcommand (`list`, `create`, `transition`, `rank`, `validate`, `statistics`, `init`, `kanban`) without requiring `--tickets-dir` on each invocation
- The `--tickets-dir` flag, where present, must take precedence over the configured value
- `init` must create the configured directory (and its `settings.yaml` with the setting recorded) rather than defaulting to `.tickets`
- The setting must support non-dot-prefixed names so the tickets directory is visible to Markdown tools such as Obsidian
- Resolution order must be well defined and documented: `--tickets-dir` flag, then configured setting, then `.tickets`/`_tickets` detection, then default
- Misconfiguration (e.g. a configured path that cannot be created or is not a directory) must produce a clear error
- Documentation (`Tickets.md`) and agent skills must describe how to set and use the configured directory

# Technical Solution

TODO

# Execution Plan

TODO 