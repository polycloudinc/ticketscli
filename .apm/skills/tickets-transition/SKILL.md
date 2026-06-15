---
name: tickets-transition
description: Use when the user asks to transition a ticket, move a ticket, or change a ticket's status. The user's message should include both the ticket code and the target status. Do not use for creating, listing, ranking, or reviewing tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Always invoke it using `npx @aleisium/tickets@latest`.

# Transition Ticket

When the user asks to transition, move, or change the status of a ticket:

1. Extract the ticket code (e.g., `TIK012`) and the target status from the user's message. The target status may appear as a canonical value (`backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`) or as a natural-language equivalent (e.g., "done" maps to `complete`, "wip" or "in progress" maps to `inprogress`, "wont fix" maps to `wontfix`). Map the user's phrasing to the closest canonical status.

2. Run `npx @aleisium/tickets@latest transition -t <code> -T <status>` using the extracted ticket code and canonical target status. The `transition` subcommand handles fuzzy matching and case-insensitive input for the target status.

3. Report the result to the user: whether the transition succeeded, or if the ticket was already in the target status.

## Target Status Mapping

| Natural Language          | Canonical   | Maps to frontmatter     |
|---------------------------|-------------|-------------------------|
| backlog, unscheduled      | `backlog`   | `"[[Backlog]]"`         |
| ready, scheduled          | `ready`     | `"[[Ready]]"`           |
| in progress, wip, active  | `inprogress`| `"[[In Progress]]"`     |
| complete, done, finished  | `complete`  | `"[[Complete]]"`        |
| duplicate, dup            | `duplicate` | `"[[Duplicate]]"`       |
| wont fix, wontfix, reject | `wontfix`   | `"[[Won't Fix]]"`       |
