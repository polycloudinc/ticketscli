---
name: tickets-rank
description: Use when the user asks to promote, demote, reorder, or change the rank of a ticket. The user's message should include both the ticket code and the direction (up, down, top, bottom). Do not use for creating, listing, reviewing, or updating ticket status.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Always invoke it using `npx @aleisium/tickets@latest`.

# Rank Ticket

When the user asks to promote, demote, reorder, or change the rank of a ticket:

1. Extract the ticket code (e.g., `TIK005`) from the user's message. The ticket code follows the pattern `<code_prefix>\d{3}` (e.g., `TIK012`). If the user's message contains multiple ticket codes, use the one associated with the ranking action.

2. Determine the direction from the user's phrasing. Map natural language to the correct `rank` subcommand using the table below.

3. Run `npx @aleisium/tickets@latest rank <subcommand> -t <code>` using the extracted ticket code and the mapped subcommand.

4. Report the result to the user verbatim. The CLI handles normalization and boundary messages internally (e.g., "Promoted TIK005 to rank 3" or "TIK001 is already at the highest priority").

## Phrase-to-Subcommand Mapping

| Natural Language                                        | Subcommand   |
|--------------------------------------------------------|--------------|
| promote, bump up, move up, rank up, increase priority  | `rank up`    |
| demote, bump down, move down, rank down, push down, decrease priority | `rank down`  |
| move to the top, send to the top, rank first, top priority, make highest | `rank first` |
| move to the bottom, send to bottom, rank last, bottom, make lowest | `rank last`  |

If the user's phrasing is ambiguous (e.g., "move TIK005") without a clear direction, ask the user whether they want to promote or demote the ticket.
