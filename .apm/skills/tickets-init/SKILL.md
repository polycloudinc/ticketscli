---
name: tickets-init
description: Use when the user asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure. Invokes the `tickets init` subcommand. Supports `--code-prefix` flag or interactive prompt. Do not use for creating, listing, ranking, reviewing, or transitioning individual tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter declaring `api: polycloudinc/ticketscli/v1` and containing fields such as `ticket_code`, `ticket_name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `backlog` (unscheduled), `ready` (scheduled), `inprogress` (active work), `complete` (done), `duplicate`, and `wontfix`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, `statistics`, and `migrate` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Initialize Tickets

When the user asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure:

1. Run `tickets init` to bootstrap the tickets system. If the user provides a code prefix, pass it via `--code-prefix`; if not, the command will prompt interactively.

   ```
   tickets init                        # interactive prompt for code prefix
   tickets init --code-prefix TKT      # specify prefix on command line
   tickets init -d custom_path          # custom tickets directory
   ```

2. The command creates the following in the current directory:
   - `.tickets/` directory containing `settings.yaml` (with the code prefix) and `statistics.yaml`

3. Report the result to the user.
