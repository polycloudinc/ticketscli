# Tickets

Tickets are Markdown files in the `_tickets/` directory with YAML frontmatter.

## Prerequisites

The `validate` subcommand requires **mikefarah/yq** (the Go implementation). The Python `yq` (`kislyuk/yq`, available via `apt`) is not compatible.

```bash
# Install the correct yq (Go)
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# Verify
yq --version  # Should show: yq (https://github.com/mikefarah/yq/) version v4.x.x
```

The dev container Dockerfile installs `yq` automatically.

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

## Validate Subcommand

`tickets validate <ticket-code>` validates a ticket's YAML front matter against the standard ticket schema.

```
tickets validate TIK001                 # validate a single ticket
tickets validate -t ./_tickets TIK001   # specify tickets directory
```

### Schema Source

The mandatory field set is derived from the ticket template at `_templates/Ticket.md`. Every field in the template must be present in each ticket.

The project code prefix is read from `_tickets/settings.yaml`:

```yaml
code_prefix: TIK
```

### Validation Checks

The command checks three categories of deviations:

1. **Missing fields** — fields in the template but absent from the ticket
2. **Unknown fields** — fields in the ticket but not in the template
3. **Invalid values** — hardcoded constraints for specific fields

| Field             | Constraint                                                       |
|-------------------|------------------------------------------------------------------|
| `template`        | Must be `"[[Ticket]]"`                                          |
| `kind`            | Must be `ticket`                                                 |
| `code`            | Must match `<code_prefix>\d{3}` (e.g. `TIK001`)                 |
| `name`            | Must be non-empty                                                |
| `aliases`         | Must contain exactly one entry matching `code`                    |
| `ticket_status`   | One of: `[[Backlog]]`, `[[Ready]]`, `[[In Progress]]`, `[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]` |
| `ticket_priority` | One of: `Low`, `Medium`, `High`, `Critical`                      |
| `tags`            | No value constraint                                              |

Deviations are printed to stderr as bullet points. Exit code 0 if valid, 1 if deviations found.

## Create Subcommand

`tickets create --name <subject>` creates a new ticket file from the template, auto-assigning the next ticket code.

| Flag                | Short | Required | Description                                          |
|---------------------|-------|----------|------------------------------------------------------|
| `--name <subject>`  | `-n`  | yes      | Subject/name for the new ticket                      |
| `--tickets-dir`     | `-d`  | no       | Path to tickets directory (default: `_tickets`)      |
| `--help`            | `-h`  | no       | Show usage text                                      |

```
tickets create --name "Add Login Page"     # create with full flag
tickets create -n "Fix Bug"                # create with short flag
tickets create -n "Custom" -d /other/dir   # create in a custom directory
```

### Behavior

The command locates the project root by walking up from the current directory to find `_templates/Ticket.md` (same approach as `cmd_validate`). It reads the `code_prefix` from `<tickets-dir>/settings.yaml` and scans existing ticket filenames to find the highest numeric suffix, then generates the next code as `<Prefix><NNN>` (zero-padded to 3 digits, starting at 001 if no tickets exist).

The template body (everything after the frontmatter) is copied into the new file. The frontmatter is populated with:

| Field              | Value                       |
|--------------------|-----------------------------|
| `code`             | Auto-assigned next code     |
| `aliases`          | Single entry matching code  |
| `name`             | Value from `--name`         |
| `ticket_status`    | `[[Backlog]]`               |
| `ticket_priority`  | `Medium`                    |

If `settings.yaml` is missing or `code_prefix` is not set, the command exits with an error. If a ticket with the generated code already exists, the command exits with an error.

## Agent Skills

The following agent skills are available to assist with ticket workflows:

| Skill              | Description                                                                 | Invoked When                                                                   |
|--------------------|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `list-tickets`     | Lists tickets from `_tickets/` with optional filtering by group or status.  | User asks to list or show tickets.                                             |
| `review-ticket`    | Reviews a ticket against the current state of the codebase for issues.      | User asks to review a ticket.                                                  |
| `execution-plan`   | Creates and manages checkbox-based execution plans with optional phasing.   | User asks to create, update, or check off execution plan items in a ticket.    |

### Execution Plan Phasing

The `execution-plan` skill splits tasks into named phases (each a level-three heading) when:

- The total number of tasks exceeds **5**, or
- Tasks touch **logically different parts of the system** that can be completed and tested individually.

Otherwise, tasks remain as a flat linear checkbox list under a single `# Execution Plan` heading.
