# Tickets

Tickets are Markdown files in the `_tickets/` directory with YAML frontmatter.

## Filename Convention

```
<TicketCode> <Subject>.md
```

Example: `TIK001 - List Subcommand.md`

## Frontmatter

```yaml
---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK001
aliases:
name: List Subcommand
subjects: cli
ticket_status: "[[Backlog]]"
ticket_priority: Medium
---
```

## Status Values

The `ticket_status` field accepts one of the following wiki-linked values:

| Status            | Description                           | Filter Group |
|-------------------|---------------------------------------|-------------|
| `[[Backlog]]`     | Not yet scheduled for work            | `--group backlog` |
| `[[Ready]]`       | Scheduled and ready to be picked up   | `--group active`  |
| `[[In Progress]]` | Currently being worked on             | `--group active`  |
| `[[Complete]]`    | Work has been finished                | `--group done`    |
| `[[Duplicate]]`   | Duplicate of another ticket           | `--group done`    |
| `[[Won't Fix]]`   | Will not be implemented               | `--group done`    |

## CLI Filters

| Flag                     | Short | Matches                                   |
|--------------------------|-------|-------------------------------------------|
| `--group backlog`        | `-g`  | `[[Backlog]]`                             |
| `--group active`         | `-g`  | `[[Ready]]`, `[[In Progress]]`            |
| `--group done`           | `-g`  | `[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]` |

Only one filter may be specified at a time.
