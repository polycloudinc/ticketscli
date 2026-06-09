---
name: tickets
description: Use when working with tickets - listing, creating, updating status, checking off execution plan items, or understanding the ticket lifecycle. Also use when the user asks about ticket commands or workflows.
---

# Tickets

The tickets system manages work items as Markdown files in the `_tickets/` directory with YAML frontmatter.

## CLI

### List Tickets

```
tickets list                  # all tickets
tickets list --active         # Ready or In Progress
tickets list --backlog        # Backlog only
tickets list --done           # Complete, Duplicate, or Won't Fix
tickets list --status Ready   # filter by specific status
tickets list -t /path/to/dir  # custom tickets directory
```

### Create a Ticket

```
tickets create --name "Feature Name"
tickets create -n "Short Form"
```

The command auto-assigns the next ticket code and sets `ticket_status` to `[[Backlog]]`.

### Manage Ranks

```
tickets rank                   # renumber all tickets sequentially
tickets rank up --ticket CODE  # promote (swap with ticket above)
tickets rank down --ticket CODE  # demote (swap with ticket below)
tickets rank first --ticket CODE  # move to rank 1
tickets rank last --ticket CODE   # move to lowest rank
```

### Kanban

```
tickets kanban                 # display tickets in kanban columns by status
```

## Status Lifecycle

| Status            | Meaning                                |
|-------------------|----------------------------------------|
| `[[Backlog]]`     | Not yet scheduled for work             |
| `[[Ready]]`       | Scheduled and ready to be picked up    |
| `[[In Progress]]` | Currently being worked on              |
| `[[Complete]]`    | Work finished                          |
| `[[Duplicate]]`   | Duplicate of another ticket            |
| `[[Won't Fix]]`   | Will not be implemented                |

## Ticket Files

Tickets are Markdown files named `<Code> <Subject>.md` in the `_tickets/` directory. The YAML frontmatter includes:

```yaml
---
code: TIK001
name: Subject
subjects: cli
ticket_status: "[[In Progress]]"
ticket_priority: Medium
ticket_rank: 3
---
```

## Agent Workflow

When implementing a ticket:

1. Read the ticket file to understand the requirements, technical solution, and execution plan.
2. Update `ticket_status` to `[[In Progress]]` when starting work.
3. Work through each execution plan checkbox in order, marking items `[x]` as they are completed.
4. After all execution plan items are done, set `ticket_status` to `[[Complete]]`.
5. Verify the final state by running `tickets list` and confirming the ticket appears under the correct filter.
6. When communicating about tickets to the user, reference them by code (e.g. `TIK001`) so they can be cross-referenced.
