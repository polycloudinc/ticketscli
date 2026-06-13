# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `list`, `validate`, and `create` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Before running any `tickets` command, determine the correct invocation:
- If `tickets.sh` exists at the repository root, use `bash tickets.sh`.
- Otherwise, use `npx @aleisium/tickets`.
