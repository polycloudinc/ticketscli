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
| `--status <value>`       | `-s`  | Tickets whose `ticket_status` matches the given value. Valid values (case-insensitive, single-word): `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`. |

Only one filter (`--group` or `--status`) may be specified at a time.

### Fuzzy Matching

Both `--group` and `--status` accept case-insensitive input and distinguishing substrings (a substring that uniquely identifies one of the valid values).

- `--group act` resolves to `active`, `--group BACKLOG` resolves to `backlog`, `--group don` resolves to `done`
- `--status prog` resolves to `inprogress`, `--status READY` resolves to `ready`, `--status won` resolves to `wontfix`
- An exact match takes priority over substring matching (e.g. `--group backlog` matches even though `backlog` is also a substring of… itself)
- If the input is ambiguous (matches multiple values), the command prints an error listing the candidates
- If the input does not match any value, the command prints an error listing all valid values
