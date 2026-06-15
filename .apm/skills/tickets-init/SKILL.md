---
name: tickets-init
description: Use when the user asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure. Invokes the `tickets init` subcommand. Supports `--code-prefix` flag or interactive prompt. Do not use for creating, listing, ranking, reviewing, or transitioning individual tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Before running any `tickets` command, determine the correct invocation:
- If `tickets.sh` exists at the repository root, use `bash tickets.sh`.
- Otherwise, use `npx @aleisium/tickets`.

# Initialize Tickets

When the user asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure:

1. Determine the correct CLI invocation (`bash tickets.sh` from the repo root, or `npx @aleisium/tickets`).

2. Run `tickets init` to bootstrap the tickets system. If the user provides a code prefix, pass it via `--code-prefix`; if not, the command will prompt interactively.

   ```
   tickets init                        # interactive prompt for code prefix
   tickets init --code-prefix TKT      # specify prefix on command line
   tickets init -d custom_path          # custom tickets directory
   ```

3. The command creates the following in the current directory:
   - `_tickets/` directory containing `settings.yaml` (with the code prefix) and `statistics.yaml`
   - `_templates/` directory containing `Ticket.md` (the ticket template)

4. Report the result to the user.
