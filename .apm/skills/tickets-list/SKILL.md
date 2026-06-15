---
name: tickets-list
description: Use when the user asks to list tickets, show tickets, or similar listing phrases. The user may include a group keyword, status value, or numeric limit (e.g., "top 5", "first 10") to filter by. Only covers the `list` subcommand.
---
# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Always invoke it using `npx @aleisium/tickets@latest`.

# List Tickets

The `tickets list` subcommand displays tickets from the `_tickets/` directory, with optional filtering by status group or specific status.

## CLI

```
tickets list                       # all tickets (no filter)
tickets list --group backlog       # Backlog tickets
tickets list --group active        # Ready and In Progress tickets
tickets list --group done          # Complete, Duplicate, and Won't Fix tickets
tickets list --group todo          # Backlog, Ready, and In Progress tickets sorted by rank
tickets list --status inprogress   # only In Progress tickets
tickets list --status wontfix      # only Won't Fix tickets
tickets list --limit 5             # first 5 tickets (after any filtering and sorting)
tickets list --limit 3 --status ready  # first 3 Ready tickets
tickets list -l 10 --group backlog     # first 10 Backlog tickets
tickets list -t /path/to/dir       # custom tickets directory
```

`--limit` (`-l`) is not a filter; it limits output to the first N tickets after filtering and sorting. It can be combined with `--group` or `--status`. N must be a positive integer >= 1. If the limit exceeds matching tickets, all are shown. When not provided, all matching tickets are displayed.`

## Filter Selection

When the user provides a keyword or alias, map it to either `--group` or `--status`:

### Group mapping

Use `--group` for broad categories:

| User says                | CLI command                    |
|--------------------------|--------------------------------|
| `backlog`                | `tickets list --group backlog` |
| `active`                 | `tickets list --group active`  |
| `done`                   | `tickets list --group done`    |
| `todo`                   | `tickets list --group todo`    |

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

If a keyword matches both a group alias and a specific status, `--status` takes priority because it is more specific. For example, "in progress" maps to `--status inprogress`, not `--group active`. Exception: `todo` maps to `--group todo` (all non-done tickets), not `--status backlog`.

## Limit Detection

When the user's prompt includes a numeric quantity with a quantity/ordinal prefix, extract it as a limit and pass `--limit` alongside any group or status filter:

| User prompt                       | CLI command                              |
|-----------------------------------|------------------------------------------|
| `show me the top 5 tickets`       | `tickets list --limit 5`                 |
| `list the first 3 ready tickets`  | `tickets list --limit 3 --status ready`  |
| `give me 10 backlogs`             | `tickets list --limit 10 --group backlog`|
| `show 20`                         | `tickets list --limit 20`                |
| `list active, top 8`              | `tickets list --limit 8 --group active`  |

Quantity/ordinal indicators that signal a limit include: `top N`, `first N`, `show N`, `give me N`, `list N`, `display N`, `limit N`, `only N`, `just N`.

When no numeric quantity is present in the user's message, do not pass `--limit` (preserving current behavior of showing all matching tickets).

### Disambiguation from ticket codes

A bare number appearing without a quantity/ordinal prefix and in a ticket-identification context should NOT be treated as a limit:

| User prompt       | Interpretation       | CLI command                    |
|-------------------|----------------------|--------------------------------|
| `show ticket 5`   | Ticket TIK005 lookup | `tickets list` (no limit)      |
| `review tik 12`   | Ticket TIK012 review | `tickets list` (no limit)      |
| `show me 5`       | Limit of 5           | `tickets list --limit 5`       |
| `list 7 active`   | Limit of 7, active   | `tickets list --limit 7 --group active` |

A number is a ticket code reference (not a limit) when it immediately follows a ticket keyword (`ticket`, `tik`) or a code-like pattern. A number is a limit when it follows a quantity/ordinal indicator or stands alone as a bare number with no ticket-identification context.

## Group Aliases

The following natural-language aliases map to `--group`:

| Group    | Aliases                                                           |
|----------|-------------------------------------------------------------------|
| backlog  | pending, unscheduled, queued, awaiting, not started                      |
| active   | in progress, current, underway, being worked, working             |
| done     | completed, finished, closed, resolved, complete                   |
| todo     | upcoming, remaining, open, outstanding                          |

## Status Aliases

The following natural-language aliases map to `--status`:

| Status     | Aliases                                                           |
|------------|-------------------------------------------------------------------|
| backlog    | pending, unscheduled, queued, awaiting, not started                       |
| ready      | scheduled, prepared, staged, standing by                          |
| inprogress | in progress, current, underway, being worked, working, wip        |
| complete   | done, completed, finished, closed, resolved                       |
| duplicate  | dupe, dup, doubled, repeated, copy, clone                         |
| wontfix    | won't fix, wont fix, will not fix, rejected, declined, wontdo     |

## Notes

- The status field in ticket frontmatter is spelled `[[Backlog]]` (single 'g'), but the CLI group flag is `backlog` (double 'g'). Use the CLI spelling (`backlog`, double 'g') for `--group`.
- Status values are case-insensitive and single-word: `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`.
- If no keyword or recognizable alias is given, run the tickets CLI `list` subcommand with no filter.
