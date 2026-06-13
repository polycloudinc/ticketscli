---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK009
aliases:
  - TIK009
name: Group Switch for List Subcommand
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 9
---

# Introduction

Add a `--group` switch to the `tickets list` subcommand that accepts `backlog`, `active`, or `done` as a value. Replace the existing standalone `-b`/`--backlog`, `-a`/`--active`, and `-d`/`--done` switches with this unified `--group` option.

# Requirements

- `tickets list` must accept `-g`/`--group <backlog|active|done>` to filter by status group.
- The old `-b`/`--backlog`, `-a`/`--active`, and `-d`/`--done` switches must be removed with no backwards compatibility.
- `-g`/`--group` must reject invalid values with a clear error message.
- Only one `--group` value may be specified at a time.
- Usage help (`list_usage`) must document the new switch.
- `Tickets.md` documentation must be updated to reflect the new flag syntax.
- The deployable package copy at `als-tickets-cli/als-tickets-cli-main/tickets.sh` must be kept in sync.

# Technical Solution

**`tickets.sh` — argument parsing (`cmd_list`, lines 29–59):**

Replace the case arm on line 40 (`--backlog|-b|--active|-a|--done|-d)`) with a `-g|--group` arm that reads the next argument as the group value and validates it against `backlog`, `active`, `done`.

```bash
-g|--group)
  [[ -z "${2:-}" ]] && { echo "Error: -g/--group requires a value (backlog, active, or done)" >&2; exit 1; }
  [[ -n "$filter" ]] && { echo "Error: only one -g/--group value may be specified" >&2; exit 1; }
  case "$2" in
    backlog|active|done) filter="$2" ;;
    *) echo "Error: invalid group '$2'. Valid groups: backlog, active, done" >&2; exit 1 ;;
  esac
  shift
  ;;
```

**`tickets.sh` — filter application (`cmd_list`, lines 76–80):**

Change the `case` statement to match the raw group name instead of the `--`-prefixed flags:

```bash
case "$filter" in
  backlog) [[ "$status" != "Backlog" ]] && continue ;;
  active)  [[ "$status" != "Ready" && "$status" != "In Progress" ]] && continue ;;
  done)    [[ "$status" != "Complete" && "$status" != "Duplicate" && "$status" != "Won't Fix" ]] && continue ;;
esac
```

**`tickets.sh` — usage text (`list_usage`, lines 16–27):**

Replace lines 22–24 with a single line documenting `--group`:

```
  -g, --group <backlog|active|done>  Filter tickets by status group
```

**`tickets.sh` — duplicate copy:**

Apply identical changes to `als-tickets-cli/als-tickets-cli-main/tickets.sh`.

**`Tickets.md` — documentation (lines 43–51):**

Replace the CLI Filters table with the new syntax:

```markdown
## CLI Filters

| Flag                     | Matches                                   |
|--------------------------|-------------------------------------------|
| `--group backlog`        | `[[Backlog]]`                             |
| `--group active`         | `[[Ready]]`, `[[In Progress]]`            |
| `--group done`           | `[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]` |
```

Also update the Filter Group column in the Status Values table (line 36–38) to reference `--group backlog`, etc.

# Execution Plan

- [x] Update `list_usage()` help text in `tickets.sh` to document `--group` and remove old flags.
- [x] Replace `--backlog|-b|--active|-a|--done|-d)` case arm in `cmd_list()` with new `--group` arm.
- [x] Update filter `case` statement in `cmd_list()` to match `backlog`/`active`/`done` instead of `--backlog`/`--active`/`--done`.
- [x] Apply identical changes to `als-tickets-cli/als-tickets-cli-main/tickets.sh`.
- [x] Update `Tickets.md` CLI Filters table and Status Values Filter Group column.
- [x] Verify `tickets list --group backlog` and `tickets list -g backlog` show only Backlog tickets.
- [x] Verify `tickets list --group active` and `tickets list -g active` show Ready and In Progress tickets.
- [x] Verify `tickets list --group done` and `tickets list -g done` show Complete, Duplicate, and Won't Fix tickets.
- [x] Verify `tickets list --group invalid` and `tickets list -g invalid` print an error.
- [x] Verify old flags (`-b`, `-a`, `-d`) produce an "Unknown option" error.
