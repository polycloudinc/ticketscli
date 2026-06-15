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

## Architecture

`tickets.sh` is a bash script that uses **mikefarah/yq** (Go) for all YAML front matter manipulation in ticket files.

### Reads

Front matter fields are read with `yq eval --front-matter extract`:

```bash
yq eval --front-matter extract '.ticket_rank // ""' "$ticket_file"
```

### Writes

Front matter fields are written with `yq eval -i --front-matter process`:

```bash
yq eval -i --front-matter process '.ticket_rank = 5' "$ticket_file"
```

The `--front-matter process` flag is required for in-place writes; using `--front-matter extract` with `-i` would strip the Markdown body content.

### Value Formatting

Timestamps are passed via `env()` to avoid YAML quoting, preserving the unquoted format produced by `printf` in `cmd_create`:

```bash
TS="2026-06-14T15:00:00Z" yq eval -i --front-matter process '.ticket_updated = env(TS)' "$ticket_file"
```

Done tickets have their `ticket_rank` cleared by setting it to `null` in yq, then post-processing with sed to produce a bare `ticket_rank:` line with no value:

```bash
yq eval -i --front-matter process '.ticket_rank = null' "$ticket"
sed -i 's/^ticket_rank: null$/ticket_rank:/' "$ticket"
```

### Creating New Front Matter

Writing front matter from scratch (e.g. in `cmd_create`) uses `printf`, not yq, since there is no existing YAML to manipulate.

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
  - TIK001
name: List Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 32
ticket_created: 2026-06-14T03:02:32Z
ticket_updated: 2026-06-14T03:02:32Z
ticket_completed:
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

The `--group todo` filter returns tickets from both `--group backlog` and `--group active` (i.e., `[[Backlog]]`, `[[Ready]]`, `[[In Progress]]`), sorted by rank.

## CLI Filters

| Flag                     | Short | Matches                                   |
|--------------------------|-------|-------------------------------------------|
| `--group backlog`        | `-g`  | `[[Backlog]]`                             |
| `--group active`         | `-g`  | `[[Ready]]`, `[[In Progress]]`            |
| `--group done`           | `-g`  | `[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]` |
| `--group todo`           | `-g`  | `[[Backlog]]`, `[[Ready]]`, `[[In Progress]]`    |
| `--status <value>`       | `-s`  | Tickets whose `ticket_status` matches the given value. Valid values (case-insensitive, single-word): `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`. |
| `--limit <N>`            | `-l`  | Limits output to the first N tickets after filtering and sorting. `N` must be a positive integer >= 1. If the limit exceeds the number of matching tickets, all are displayed.

Only one filter (`--group` or `--status`) may be specified at a time. `--limit` is not a filter and may be combined with `--group` or `--status`.

### List Table Output

The `list` subcommand renders tickets as a four-column table: **Code**, **Subject**, **Rank**, and **Status**.

Output adapts to the available terminal width (detected via `tput cols` with a fallback to `$COLUMNS`/`80`). Column widths are computed as follows:

| Column   | Width                                              |
|----------|----------------------------------------------------|
| Code     | Fixed at 8                                         |
| Rank     | Fixed at 5                                         |
| Status   | Fixed at 12                                        |
| Subject  | `terminal_width - 8 - 5 - 12 - 3` (3 accounts for inter-column spaces), clamped to a minimum of 10 |

The Subject column absorbs all remaining space. When a subject exceeds the computed Subject width, it is truncated at `subject_width - 3` characters and `...` is appended.

On extremely narrow terminals (below ~40 columns), column minimums are enforced and line overflow is tolerated rather than breaking table structure.

Completed, duplicate, and won't-fix tickets display `-` in the Rank column. All other tickets display their numeric rank.

### Fuzzy Matching

Both `--group` and `--status` accept case-insensitive input and distinguishing substrings (a substring that uniquely identifies one of the valid values).

- `--group act` resolves to `active`, `--group BACKLOG` resolves to `backlog`, `--group don` resolves to `done`, `--group tod` resolves to `todo`
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

The mandatory field set is derived from the ticket template at `_templates/Ticket.md`. Every field in the template must be present in each ticket, with the exception of `ticket_updated` which is optional.

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
| `ticket_rank`     | Must be present and hold an integer value                      |
| `ticket_created`  | Must be ISO 8601 UTC (e.g. `2026-06-13T14:30:00Z`)             |
| `ticket_updated`  | Optional; if present, must be ISO 8601 UTC                      |
| `ticket_completed`| Must be ISO 8601 UTC or empty (set automatically by `tickets transition`) |
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
| `ticket_rank`       | `max_existing_rank + 1` (or `1` if no tickets exist) |
| `ticket_created`    | Current UTC timestamp in ISO 8601 format (`YYYY-MM-DDThh:mm:ssZ`) |

If `settings.yaml` is missing or `code_prefix` is not set, the command exits with an error. If a ticket with the generated code already exists, the command exits with an error.

## Init Subcommand

`tickets init` bootstraps a new project with the required directory structure, settings, and ticket template.

| Flag                  | Short | Required | Description                                                   |
|-----------------------|-------|----------|---------------------------------------------------------------|
| `--code-prefix`       |       | no       | Ticket code prefix (3-4 alpha characters); if omitted, prompted interactively |
| `--tickets-dir`       | `-d`  | no       | Path to tickets directory (default: `_tickets`)                |
| `--help`              | `-h`  | no       | Show usage text                                                |

```
tickets init                                    # interactive prompt for code prefix
tickets init --code-prefix TKT                  # specify prefix on command line
tickets init --code-prefix TKT -d custom_path   # custom tickets directory
```

### Behavior

The command creates the following structure relative to the current directory:

```
_templates/
  Ticket.md            # copied from the built-in template
_tickets/
  settings.yaml        # contains code_prefix
  statistics.yaml      # initialized with statistics: []
```

If `settings.yaml` already exists in the target tickets directory, the command halts with an error to prevent overwriting a previously initialized project.

### Code Prefix

The code prefix is used by `tickets create` when generating ticket codes (e.g. `TKT001`). When `--code-prefix` is not supplied, the command interactively prompts for a value. In both cases, the input is validated:

- Must be 3 or 4 alphabetic characters (A-Z, a-z)
- Lowercase input is automatically uppercased for storage
- Invalid input from the prompt causes a re-prompt; invalid input from the flag causes an error

### Template Resolution

The ticket template is located by reading the `tickets.templateModule` reference from the CLI module's `package.json`, which points to `als-tickets-template/als-tickets-template-main/Ticket.md`. If the template cannot be found via `package.json` (e.g. when running from the repo root), the command falls back to walking up the directory tree from the current working directory to find `_templates/Ticket.md`, the same approach used by `tickets create` and `tickets validate`.

## Rank Subcommand

`tickets rank` normalizes ranks across all tickets, closing gaps by reassigning contiguous 1..N integers while preserving the existing relative ordering.

```
tickets rank                         # normalize all ranks
tickets rank -d /other/dir           # normalize in a custom directory
```

### Rank Mutation Subcommands

| Subcommand   | Description                                                                  |
|-------------|------------------------------------------------------------------------------|
| `rank up`   | Promote a ticket's priority. Swaps the target ticket's rank with the ticket at `rank - 1`. Accepts `--ticket` / `-t`. |
| `rank down` | Demote a ticket's priority. Swaps the target ticket's rank with the ticket at `rank + 1`. Accepts `--ticket` / `-t`. |
| `rank first` | Move a ticket to rank 1, shifting all tickets between the old and new positions down by 1. Accepts `--ticket` / `-t`. |
| `rank last`  | Move a ticket to the lowest rank, shifting all tickets between the old and new positions up by 1. Accepts `--ticket` / `-t`. |

```
tickets rank up --ticket TIK003      # promote TIK003
tickets rank down -t TIK005          # demote TIK005
tickets rank first --ticket TIK004   # move TIK004 to rank 1
tickets rank last -t TIK002          # move TIK002 to lowest rank
```

All mutation subcommands normalize ranks first (closing gaps) before applying the operation. If the target is already at the boundary (rank 1 for `up`/`first`, highest rank number for `down`/`last`), the command prints a message and exits without changes.

### List Sorting

The `tickets list` output is sorted ascending by `ticket_rank`. Tickets without a rank or with a non-integer rank value sort after all ranked tickets.

## Transition Subcommand

`tickets transition --ticket <code> --target <status>` changes a ticket's `ticket_status` with built-in business rules for rank management.

| Flag                | Short | Required | Description                                          |
|---------------------|-------|----------|------------------------------------------------------|
| `--ticket <code>`   | `-t`  | yes      | Ticket code to transition (e.g., `TIK001`)           |
| `--target <status>` | `-T`  | yes      | Target status (case-insensitive, fuzzy-matched)      |
| `--tickets-dir`     | `-d`  | no       | Path to tickets directory (default: `_tickets`)      |
| `--help`            | `-h`  | no       | Show usage text                                      |

```
tickets transition --ticket TIK001 --target inprogress
tickets transition -t TIK019 -T complete
tickets transition --ticket TIK003 --target ready -d /other/dir
```

### Target Status Values

The `--target` switch accepts the same canonical status values as the `--status` flag on the `list` subcommand: `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`. Input is case-insensitive and supports distinguishing substrings (e.g., `comp` uniquely resolves to `complete`). Ambiguous or invalid inputs produce an error listing the valid values or candidates.

| Canonical     | Maps to frontmatter       |
|---------------|---------------------------|
| `backlog`     | `"[[Backlog]]"`           |
| `ready`       | `"[[Ready]]"`             |
| `inprogress`  | `"[[In Progress]]"`       |
| `complete`    | `"[[Complete]]"`          |
| `duplicate`   | `"[[Duplicate]]"`         |
| `wontfix`     | `"[[Won't Fix]]"`         |

### Behavior

Any transition from any status to any status is allowed. If the ticket is already in the target status, the command prints a message and exits without changes.

**Transitioning to a done status** (`complete`, `duplicate`, `wontfix`):

- The `ticket_rank` field is cleared.
- The `ticket_completed` field is set to the current UTC ISO 8601 timestamp (e.g. `2026-06-14T03:02:32Z`). If the field does not yet exist, it is created after `ticket_updated`.
- Rank normalization is triggered (reusing the same logic as `tickets rank`), closing gaps across all tickets.

**Transitioning to an active status** (`backlog`, `ready`, `inprogress`):

- The `ticket_completed` field is cleared (set to empty).
- If the ticket was previously in a done status and the `ticket_rank` field is empty, it is set to `max_existing_rank + 1`, placing the reactivated ticket at the end of the active ranked set.
- No normalization is triggered on reactivation.

## Statistics Subcommand

`tickets statistics snapshot` computes metrics from the current ticket corpus and appends the results as a timestamped record to `_tickets/statistics.yaml`, enabling trend analysis over time.

### CLI Interface

```
Usage: tickets statistics snapshot [options]

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```

Running `tickets statistics` without `snapshot` prints usage and exits.

### Metrics Computed

- **Total tickets** — count of all `.md` files in `_tickets/`.
- **Count by status** — breakdown for each status: Backlog, Ready, In Progress, Complete, Duplicate, Won't Fix.
- **Todo count** — tickets in Backlog, Ready, or In Progress.
- **Done count** — tickets in Complete, Duplicate, or Won't Fix.

If the tickets directory is empty (no `.md` files), all counts are zero and a snapshot is still recorded.

### Stdout Format

Metrics are printed to stdout as key-value pairs:

```
ts: 2026-06-14T07:30:00Z
total: 34
status:
  backlog: 12
  ready: 5
  inprogress: 1
  complete: 14
  duplicate: 1
  wontfix: 1
groups:
  todo: 18
  done: 16
```

### Snapshot Recording

Each invocation appends a snapshot record to `_tickets/statistics.yaml`:

```yaml
statistics:
  - ts: 2026-06-14T07:30:00Z
    total: 34
    status:
      backlog: 12
      ready: 5
      inprogress: 1
      complete: 14
      duplicate: 1
      wontfix: 1
    groups:
      todo: 18
      done: 16
```

The file is append-only; existing records are never modified. If `_tickets/statistics.yaml` does not exist, it is created. The `list` and `validate` subcommands ignore `statistics.yaml` (it does not match the ticket filename convention).

## Agent Skills

The following agent skills are available to assist with ticket workflows:

| Skill              | Description                                                                 | Invoked When                                                                   |
|--------------------|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `tickets-init`          | Initializes the tickets system in a new project using the `tickets init` CLI subcommand. Supports `--code-prefix` flag or interactive prompt. | User asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure. |
| `tickets-create`        | Creates a new ticket from the template with auto-assigned code. Extracts a name from the user's message and uses the `tickets create` subcommand. | User asks to create a new ticket.                                               |
| `tickets-list`          | Lists tickets from `_tickets/` with optional filtering by group, status, or a numeric limit (e.g., "top 5", "first 10").  | User asks to list or show tickets.                                             |
| `tickets-review`        | Reviews a ticket against the current state of the codebase for issues. Also accepts "review next ticket" to automatically locate and review the highest-ranked upcoming ticket.   | User asks to review a ticket or says "review next ticket".                     |
| `tickets-execution-plan`| Creates and manages checkbox-based execution plans with optional phasing.   | User asks to create, update, or check off execution plan items in a ticket.    |
| `tickets-transition`    | Transitions a ticket between statuses using the `tickets transition` CLI.  | User asks to transition, move, or change the status of a ticket.               |
| `tickets-rank`          | Adjusts ticket priority with the `tickets rank` CLI subcommands (`up`, `down`, `first`, `last`). | User asks to promote, demote, reorder, or change the rank of a ticket.         |

### Execution Plan Phasing

The `tickets-execution-plan` skill splits tasks into named phases (each a level-three heading) when:

- The total number of tasks exceeds **5**, or
- Tasks touch **logically different parts of the system** that can be completed and tested individually.

Otherwise, tasks remain as a flat linear checkbox list under a single `# Execution Plan` heading.
