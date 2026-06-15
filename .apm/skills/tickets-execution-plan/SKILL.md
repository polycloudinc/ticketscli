---
name: tickets-execution-plan
description: Use when the user asks to create, update, or check off execution plan items in a ticket. Do not use for listing, creating, updating ticket status, ranking, kanban, or reviewing tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Before running any `tickets` command, determine the correct invocation:
- If `tickets.sh` exists at the repository root, use `bash tickets.sh`.
- Otherwise, use `npx @aleisium/tickets`.

# Execution Plan

Create a linear checkbox list of tasks under an `# Execution Plan` heading. Use `- [ ]` for pending and `- [x]` for completed tasks.

## Phases

Break tasks into separate phases (each a level-three heading `## Phase Name`) when:

- The total number of tasks **exceeds 5**, or
- Tasks touch **logically different parts of the system** that can be completed and tested individually — each distinct component becomes its own phase.

## Format

```markdown
# Execution Plan

## Phase Name

- [ ] Task description
- [ ] Task description

## Phase Name

- [x] Completed task
- [ ] Pending task
```
