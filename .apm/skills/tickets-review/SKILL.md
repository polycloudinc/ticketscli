---
name: tickets-review
description: Use when the user asks to review a ticket against the current state of the codebase, or says "review next ticket" to review the highest-ranked upcoming ticket. The skill handles reviewing a specific ticket by name/code, reviewing the current ticket, and reviewing the next highest-ranked ticket. Do not use for creating, ranking, kanban, or updating ticket status.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Review Ticket

Read the ticket file and review it against the current state of the codebase. Identify any open questions, inconsistencies, or ambiguities.

Respond in three sections:

**Ticket Status**

The ticket code, name, and current status in the format `<ID> - <Name> - <Status>` (status as plain text, no brackets or quotes).

**Open Issues**

A numbered list of open questions, inconsistencies, or mis-alignment with the current state of the code. Each issue must include a short summary of the recommended solution and may offer multiple solution options labelled **Option A**, **Option B**, **Option C**, etc.

If no issues are identified, output:

**No issues identified.**

**Readiness**

A one-liner stating whether the ticket appears ready to be worked or not.

## Review Next Ticket

When the user says "review next ticket" and no specific ticket code or name is provided:

1. Run `npx @polycloudinc/ticketscli@latest list -l 1` to get the single highest-ranked ticket.
2. Take the first ticket from the output (the one with the lowest `ticket_rank` value).
3. Read that ticket file and review it using the standard procedure above.
