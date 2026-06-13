---
name: list-tickets
description: Use when the user asks to list tickets, show tickets, or similar listing phrases. The user may include a group keyword or status value to filter by. Only covers the `list` subcommand.
---
# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `list`, `validate`, and `create` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Before running any `tickets` command, determine the correct invocation:
- If `tickets.sh` exists at the repository root, use `bash tickets.sh`.
- Otherwise, use `npx @aleisium/tickets`.

# List Tickets

The `tickets list` subcommand displays tickets from the `_tickets/` directory, with optional filtering by status group or specific status.

## CLI

```
tickets list                       # all tickets (no filter)
tickets list --group backlog       # Backlog tickets
tickets list --group active        # Ready and In Progress tickets
tickets list --group done          # Complete, Duplicate, and Won't Fix tickets
tickets list --status inprogress   # only In Progress tickets
tickets list --status wontfix      # only Won't Fix tickets
tickets list -t /path/to/dir       # custom tickets directory
```

## Filter Selection

When the user provides a keyword or alias, map it to either `--group` or `--status`:

### Group mapping

Use `--group` for broad categories:

| User says                | CLI command                    |
|--------------------------|--------------------------------|
| `backlog`                | `tickets list --group backlog` |
| `active`                 | `tickets list --group active`  |
| `done`                   | `tickets list --group done`    |

### Status mapping

Use `--status` for specific status values (case-insensitive, single-word):

| User says      | CLI command                         |
|----------------|-------------------------------------|
| `ready`        | `tickets list --status ready`       |
| `in progress`  | `tickets list --status inprogress`  |
| `complete`     | `tickets list --status complete`    |
| `duplicate`    | `tickets list --status duplicate`   |
| `won't fix`    | `tickets list --status wontfix`     |

### Priority rule

If a keyword matches both a group alias and a specific status, `--status` takes priority because it is more specific. For example, "in progress" maps to `--status inprogress`, not `--group active`.

## Group Aliases

The following natural-language aliases map to `--group`:

| Group    | Aliases                                                           |
|----------|-------------------------------------------------------------------|
| backlog  | pending, unscheduled, queued, awaiting, todo, to-do, not started, upcoming |
| active   | in progress, current, underway, being worked, working             |
| done     | completed, finished, closed, resolved, complete                   |

## Status Aliases

The following natural-language aliases map to `--status`:

| Status     | Aliases                                                           |
|------------|-------------------------------------------------------------------|
| backlog    | pending, unscheduled, queued, awaiting, todo, to-do, not started, upcoming |
| ready      | scheduled, prepared, staged, standing by                          |
| inprogress | in progress, current, underway, being worked, working, wip        |
| complete   | done, completed, finished, closed, resolved                       |
| duplicate  | dupe, dup, doubled, repeated, copy, clone                         |
| wontfix    | won't fix, wont fix, will not fix, rejected, declined, wontdo     |

## Notes

- The status field in ticket frontmatter is spelled `[[Backlog]]` (single 'g'), but the CLI group flag is `backlog` (double 'g'). Use the CLI spelling (`backlog`, double 'g') for `--group`.
- Status values are case-insensitive and single-word: `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`.
- If no keyword or recognizable alias is given, run the tickets CLI `list` subcommand with no filter.
