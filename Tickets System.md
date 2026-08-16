# Introduction

The ticketscli project lets you manage tickets using a terminal-based CLI and also using agent skills.

With ticketscli you can:
- Implement spec-driven development (SDD)
- Capture your complete backlog in Git
- Plan your project and track execution
- Track code changes and backlog changes together

# Demo / Quick Start

TODO

# Tickets

A ticket represents a feature, a bug fix, it some other piece of work to be done on your project.  Other work planning systems use different names for these - for example JIRA calls these "Issues" and Azure DevOps calls them "Work Items".

A ticket is simply a Markdown file created from our template and stored in the `.tickets/` directory in your project.  A ticket has a code which identifies it, and a name, and ticket files are named with the following pattern:

```
<code> - <name>.md
```

For example: `TIK001 - List Subcommand.md`

The code and name are stored in the ticket file as YAML front matter along with other attributes.  The structure of a ticket is defined by the following template which is embedded in ticketscli:

<!-- misc_template:start -->
```markdown
---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code:
aliases:
name:
ticket_status:
ticket_priority:
ticket_rank:
ticket_created:
ticket_updated:
ticket_completed:
---
```
<!-- misc_template:end -->

A ticket's status may be:
- Backlog
- Ready
- In Progress
- Completed
- Duplicate
- Won't Fix

At the moment there is no state machine to govern transitions, and any status may transition to any other status.  This might be changed in the future.

The body of the ticket has the following sections:
- **Introduction** - typically a one-liner stating the purpose of the ticket.
- **Requirements** - the requirements in business or outcome terms without dictating technical solution.
- **Technical Solution** - the solution design with the specific technical choices that have been made.
- **Execution Plan** - a flat linear list of tasks, broken into logical phases, with verification steps that must pass before exiting each phase.

The ticketscli project itself is managed with ticketscli, and you can browse it's backlog for examples of real tickets: https://github.com/polycloudinc/ticketscli/tree/master/.tickets

# Workflow

Regardless of whether you are interacting with the tickets system directly or through agent skills, ...

# Command-Line Interface (CLI)

## Introduction

The CLI is the primary way of working with the tickets system, and you can fully manage your project backlog and roadmap vie CLI.

This section walks through the subcommands offered by the CLI in logical order.

## init

The `init` subcommand initializes the Tickets system, setting up the .tickets/ directory and it's `settings.yaml` configuration file.

<!-- cli_init_help:start -->
```
$ tickets init --help

Usage: tickets init [options]

Options:
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  --code-prefix <prefix>      Ticket code prefix (3-4 alpha characters)
  -h, --help                  Show this help message
```
<!-- cli_init_help:end -->

Typically this command is used only once when you're starting a new project:

<!-- cli_init_example:start -->
```bash
$ mkdir myproj
$ cd myproj
$ git init .
$ tickets init --code-prefix MYP
Created: .tickets/
Created: .tickets/settings.yaml
Created: .tickets/statistics.yaml
$ git add .
$ git commit -m "Scaffold project"
```

Resultant settings.yaml file in the `.tickets/` directory:

```yaml
code_prefix: MYP
```
<!-- cli_init_example:end -->

## create

The `create` subcommand creates a new ticket.  It generates the ticket from the built-in template and injects values into the ticket's YAML front matter.

<!-- cli_create_help:start -->
```
$ tickets create --help

Usage: tickets create --name <subject> [options]

Options:
  -n, --name <subject>       Subject/name for the new ticket (required)
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_create_help:end -->

Example usage:

<!-- cli_create_example:start -->
```bash
$ tickets create --name "Add database connection pool to service"

Created: .tickets/MYP001 - Add database connection pool to service.md

$ tickets create -n "Fix Bug"

Created: .tickets/MYP002 - Fix Bug.md
```

Resultant ticket file:

```markdown
---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: MYP001
aliases:
  - MYP001
name: Add database connection pool to service
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 1
ticket_created: 2026-01-01T00:00:00Z
ticket_updated: 2026-01-01T00:00:00Z
ticket_completed:
---
# Introduction

TODO

# Requirements

TODO

# Technical Solution

TODO

# Execution Plan

TODO
```
<!-- cli_create_example:end -->

## list

The `list` subcommand let's you list some or all of the tickets in your project.

<!-- cli_list_help:start -->
```
$ tickets list --help

Usage: tickets list [options]

Output is sorted ascending by ticket_rank. Tickets without a rank or with
a non-integer rank value sort last.

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -g, --group <backlog|active|done|todo>  Filter tickets by status group
  -l, --limit <N>           Limit output to the first N tickets after filtering and sorting
  -s, --status <status>    Filter by status (exact or distinguishing substring, case-insensitive)
  -h, --help                Show this help message
```
<!-- cli_list_help:end -->

Example usage:

<!-- cli_list_example:start -->
```bash
$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 Backlog     
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets list --status complete

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST004   Delta Ticket                                             - Complete    
-------- ---------------------------------------------------- ----- ------------
1 matching from 6 total tickets
```
<!-- cli_list_example:end -->

## rank

The `rank` subcommand let's you change the planned execution order of your backlog.  `rank` has four subcommands of it's own:
- `rank up` - moves a ticket up one slot
- `rank down` - moves a ticket down one slot
- `rank first` - moves a ticket to the top of ranked list
- `rank last` - moves a ticket to the bottom of the ranked list

All four subcommands have the same switches:

<!-- cli_rank_up_help:start -->
```
$ tickets rank up --help

Usage: tickets rank up --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to promote
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_rank_up_help:end -->

Example usage:

<!-- cli_rank_example:start -->
```bash
$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 Backlog     
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets rank first --ticket TST003

3 ticket(s) normalized.
Moved TST003 to rank 1.

$ tickets rank down -t TST002

3 ticket(s) normalized.
Demoted TST002 to rank 3.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST003   Charlie Ticket                                           1 In Progress 
TST001   Alpha Ticket                                             2 Backlog     
TST002   Bravo Ticket                                             3 Ready       
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets
```
<!-- cli_rank_example:end -->

## transition

The `transition` subcommand manages the process of transitioning a ticket from one status to another.

<!-- cli_transition_help:start -->
```
$ tickets transition --help

Usage: tickets transition --ticket <code> --target <status> [options]

Options:
  -t, --ticket <code>        Ticket code to transition
  -T, --target <status>      Target status (backlog, ready, inprogress, complete, duplicate, wontfix; case-insensitive, fuzzy-matched)
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_transition_help:end -->

Example usage:

<!-- cli_transition_example:start -->
```bash
$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 Backlog     
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition --ticket TST001 --target inprogress

Transitioned TST001 to 'inprogress'.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 In Progress 
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition -t TST001 -T complete

Transitioned TST001 to 'complete'.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST003   Charlie Ticket                                           2 In Progress 
TST001   Alpha Ticket                                             - Complete    
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ cp -a .tickets other


$ tickets list -d other

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST003   Charlie Ticket                                           2 In Progress 
TST001   Alpha Ticket                                             - Complete    
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition --ticket TST003 --target ready -d other

Transitioned TST003 to 'ready'.

$ tickets list -d other

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST003   Charlie Ticket                                           2 Ready       
TST001   Alpha Ticket                                             - Complete    
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets
```

Transitioned ticket file:

```markdown
---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TST001
aliases:
- TST001
name: Alpha Ticket
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank: null
ticket_created: '2026-01-01T00:00:00Z'
ticket_updated: '2026-01-01T00:00:00Z'
ticket_completed: '2026-01-01T00:00:00Z'
---
# Introduction

Fixture ticket in Backlog status.

# Requirements

- Fixture requirement

# Technical Solution

TODO

# Execution Plan

TODO
```
<!-- cli_transition_example:end -->

## validate

The `validate` command checks the structure of tickets in the `.tickets/` directory against the template to identify any differences in the schema of the YAML front matter.

<!-- cli_validate_help:start -->
```
$ tickets validate --help

Usage: tickets validate [--all | --ticket <code>] [options]

Options:
  -a, --all                 Validate all tickets
  -t, --ticket <code>       Validate a single ticket by code
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```
<!-- cli_validate_help:end -->

Example usage:

<!-- cli_validate_example:start -->
```bash
$ tickets validate --ticket TST001

Validating: .tickets/TST001 - Alpha Ticket.md

$ tickets validate --ticket TST001 -d other

Validating: other/TST001 - Alpha Ticket.md
```
<!-- cli_validate_example:end -->

## statistics

The `statistics` command lets you track metrics related to your backlog and tickets.

This capability is still a work in progress and currently provides a snapshot subcommand that records the point in time metrics regarding your tickets to `.tickets/statistics.yaml`.

<!-- cli_statistics_snapshot_help:start -->
```
$ tickets statistics snapshot --help

Usage: tickets statistics snapshot [options]

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```
<!-- cli_statistics_snapshot_help:end -->

Example usage:

<!-- cli_statistics_snapshot_example:start -->
```bash
$ tickets statistics snapshot

ts: 2026-01-01T00:00:00Z
total: 6
status:
  backlog: 1
  ready: 1
  inprogress: 1
  complete: 1
  duplicate: 1
  wontfix: 1
groups:
  todo: 3
  done: 3
```

The snapshot is also appended to `.tickets/statistics.yaml` as a timestamped record:

```yaml
statistics:
- ts: '2026-01-01T00:00:00Z'
  total: 6
  status:
    backlog: 1
    ready: 1
    inprogress: 1
    complete: 1
    duplicate: 1
    wontfix: 1
  groups:
    todo: 3
    done: 3
```
<!-- cli_statistics_snapshot_example:end -->

## Installing the CLI


# Agent Skills


## Installing the Agent Skills


# Feature Roadmap

The highest priority right now is to rewrite the CLI on Rust.  It is currently just a big Bash script which was really just a proof-of-concept.  While it is fully functional, it had some rough edges around distribution (through npm) and Python dependencies for front matter processing.  These rough edges add adoption friction.

Once the Rust rewrite is done and the distribution is smoother, there are quite a number of features planned to help with planning and executing work.

The backlog is as follows:

```
TODO
```

## Prerequisites

The CLI requires **Python 3** and the **PyYAML** library. YAML operations are handled by a bundled Python helper script (`yz.py`) instead of an external `yq` binary.

```bash
# Install dependencies
pip install pyyaml

# Verify
python3 -c "import yaml; print(yaml.__version__)"
tickets validate --all   # should pass without errors
```

The dev container Dockerfile installs Python 3 and PyYAML automatically.

## Directory Resolution

The CLI resolves the tickets directory on every invocation:

| Condition | Behavior |
|---|---|
| `--tickets-dir` / `-d` flag provided | Uses the given path (no resolution) |
| `.tickets/` exists, `_tickets/` does not | Uses `.tickets/` (silent) |
| `_tickets/` exists, `.tickets/` does not | Uses `_tickets/` and prints a deprecation warning to stderr: `Warning: _tickets is deprecated. Rename the directory to .tickets to migrate.` |
| Both exist | Error: `Error: both .tickets and _tickets directories exist. Remove one or use --tickets-dir.` |
| Neither exists | Defaults to `.tickets/` |



# Implementation Notes

`tickets.sh` is a bash script that delegates all YAML operations to a bundled Python helper (`yz.py`) using PyYAML. The helper is located alongside `tickets.sh` in the npm package and handles both front matter manipulation in Markdown files and plain YAML file operations.

### Reads

Front matter fields are read with `yz.py extract`:

```bash
python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_rank
```

### Writes

Front matter fields are written with `yz.py update`:

```bash
python3 "$SCRIPT_DIR/yz.py" update "$ticket_file" .ticket_rank 5
```

### Value Formatting

Timestamps are passed via environment variables using `yz.py set-env`:

```bash
TS="2026-06-14T15:00:00Z" python3 "$SCRIPT_DIR/yz.py" set-env "$ticket_file" .ticket_updated TS
```

Done tickets have their `ticket_rank` cleared by setting it to `null` in yz.py, then post-processing with sed to produce a bare `ticket_rank:` line with no value:

```bash
python3 "$SCRIPT_DIR/yz.py" update "$ticket" .ticket_rank null
sed -i 's/^ticket_rank: null$/ticket_rank:/' "$ticket"
```

### Creating New Front Matter

Writing front matter from scratch (e.g. in `cmd_create`) uses `printf`, not yq, since there is no existing YAML to manipulate.


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

<!-- cli_validate_help:start -->
```
$ tickets validate --help

Usage: tickets validate [--all | --ticket <code>] [options]

Options:
  -a, --all                 Validate all tickets
  -t, --ticket <code>       Validate a single ticket by code
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```
<!-- cli_validate_help:end -->

<!-- cli_validate_example:start -->
```bash
$ tickets validate --ticket TST001

Validating: .tickets/TST001 - Alpha Ticket.md

$ tickets validate --ticket TST001 -d other

Validating: other/TST001 - Alpha Ticket.md
```
<!-- cli_validate_example:end -->

### Schema Source

The mandatory field set is derived from the ticket template at `Ticket.md` alongside `tickets.sh`. Every field in the template must be present in each ticket, with the exception of `ticket_updated` which is optional.

The project code prefix is read from `.tickets/settings.yaml`:

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
| `--tickets-dir`     | `-d`  | no       | Path to tickets directory (default: `.tickets`)      |
| `--help`            | `-h`  | no       | Show usage text                                      |

### Behavior

The command locates the template from the directory where `tickets.sh` resides. It reads the `code_prefix` from `<tickets-dir>/settings.yaml` and scans existing ticket filenames to find the highest numeric suffix, then generates the next code as `<Prefix><NNN>` (zero-padded to 3 digits, starting at 001 if no tickets exist).

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
| `--tickets-dir`       | `-d`  | no       | Path to tickets directory (default: `.tickets`)                |
| `--help`              | `-h`  | no       | Show usage text                                                |

<!-- cli_init_flags_example:start -->
```bash
$ tickets init --code-prefix TKT

Created: .tickets/
Created: .tickets/settings.yaml
Created: .tickets/statistics.yaml

$ tickets init --code-prefix TKT -d custom_path

Created: custom_path/
Created: custom_path/settings.yaml
Created: custom_path/statistics.yaml
```
<!-- cli_init_flags_example:end -->

### Behavior

The command creates the following structure relative to the current directory:

```
.tickets/
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

The ticket template is always resolved from the directory where `tickets.sh` resides (`$(dirname "$(readlink -f "$0")")/Ticket.md`). Both `tickets create` and `tickets validate` locate the template alongside the script itself. The `tickets init` subcommand no longer copies the template into the project directory.

## Rank Subcommand

`tickets rank` normalizes ranks across all tickets, closing gaps by reassigning contiguous 1..N integers while preserving the existing relative ordering.

<!-- cli_rank_example:start -->
```bash
$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 Backlog     
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets rank first --ticket TST003

3 ticket(s) normalized.
Moved TST003 to rank 1.

$ tickets rank down -t TST002

3 ticket(s) normalized.
Demoted TST002 to rank 3.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST003   Charlie Ticket                                           1 In Progress 
TST001   Alpha Ticket                                             2 Backlog     
TST002   Bravo Ticket                                             3 Ready       
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets
```
<!-- cli_rank_example:end -->

### Rank Mutation Subcommands

| Subcommand   | Description                                                                  |
|-------------|------------------------------------------------------------------------------|
| `rank up`   | Promote a ticket's priority. Swaps the target ticket's rank with the ticket at `rank - 1`. Accepts `--ticket` / `-t`. |
| `rank down` | Demote a ticket's priority. Swaps the target ticket's rank with the ticket at `rank + 1`. Accepts `--ticket` / `-t`. |
| `rank first` | Move a ticket to rank 1, shifting all tickets between the old and new positions down by 1. Accepts `--ticket` / `-t`. |
| `rank last`  | Move a ticket to the lowest rank, shifting all tickets between the old and new positions up by 1. Accepts `--ticket` / `-t`. |

<!-- cli_rank_mutations_example:start -->
```bash
$ tickets rank up --ticket TST003

3 ticket(s) normalized.
Promoted TST003 to rank 2.

$ tickets rank down -t TST001

3 ticket(s) normalized.
Ticket TST001 is already at the lowest priority.

$ tickets rank first --ticket TST003

3 ticket(s) normalized.
Moved TST003 to rank 1.

$ tickets rank last -t TST003

3 ticket(s) normalized.
Moved TST003 to rank 3.
```
<!-- cli_rank_mutations_example:end -->

<!-- cli_rank_down_help:start -->
```
$ tickets rank down --help

Usage: tickets rank down --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to demote
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_rank_down_help:end -->

<!-- cli_rank_first_help:start -->
```
$ tickets rank first --help

Usage: tickets rank first --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to move to rank 1
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_rank_first_help:end -->

<!-- cli_rank_last_help:start -->
```
$ tickets rank last --help

Usage: tickets rank last --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to move to the lowest rank
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_rank_last_help:end -->

All mutation subcommands normalize ranks first (closing gaps) before applying the operation. If the target is already at the boundary (rank 1 for `up`/`first`, highest rank number for `down`/`last`), the command prints a message and exits without changes.

### List Sorting

The `tickets list` output is sorted ascending by `ticket_rank`. Tickets without a rank or with a non-integer rank value sort after all ranked tickets.

## Transition Subcommand

`tickets transition --ticket <code> --target <status>` changes a ticket's `ticket_status` with built-in business rules for rank management.

<!-- cli_transition_help:start -->
```
$ tickets transition --help

Usage: tickets transition --ticket <code> --target <status> [options]

Options:
  -t, --ticket <code>        Ticket code to transition
  -T, --target <status>      Target status (backlog, ready, inprogress, complete, duplicate, wontfix; case-insensitive, fuzzy-matched)
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
```
<!-- cli_transition_help:end -->

| Flag                | Short | Required | Description                                          |
|---------------------|-------|----------|------------------------------------------------------|
| `--ticket <code>`   | `-t`  | yes      | Ticket code to transition (e.g., `TIK001`)           |
| `--target <status>` | `-T`  | yes      | Target status (case-insensitive, fuzzy-matched)      |
| `--tickets-dir`     | `-d`  | no       | Path to tickets directory (default: `.tickets`)      |
| `--help`            | `-h`  | no       | Show usage text                                      |

<!-- cli_transition_example:start -->
```bash
$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 Backlog     
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition --ticket TST001 --target inprogress

Transitioned TST001 to 'inprogress'.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST001   Alpha Ticket                                             2 In Progress 
TST003   Charlie Ticket                                           3 In Progress 
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition -t TST001 -T complete

Transitioned TST001 to 'complete'.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST003   Charlie Ticket                                           2 In Progress 
TST001   Alpha Ticket                                             - Complete    
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ cp -a .tickets other


$ tickets list -d other

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST003   Charlie Ticket                                           2 In Progress 
TST001   Alpha Ticket                                             - Complete    
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition --ticket TST003 --target ready -d other

Transitioned TST003 to 'ready'.

$ tickets list -d other

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 Ready       
TST003   Charlie Ticket                                           2 Ready       
TST001   Alpha Ticket                                             - Complete    
TST004   Delta Ticket                                             - Complete    
TST005   Echo Ticket                                              - Duplicate   
TST006   Foxtrot Ticket                                           - Won't Fix   
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets
```

Transitioned ticket file:

```markdown
---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TST001
aliases:
- TST001
name: Alpha Ticket
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank: null
ticket_created: '2026-01-01T00:00:00Z'
ticket_updated: '2026-01-01T00:00:00Z'
ticket_completed: '2026-01-01T00:00:00Z'
---
# Introduction

Fixture ticket in Backlog status.

# Requirements

- Fixture requirement

# Technical Solution

TODO

# Execution Plan

TODO
```
<!-- cli_transition_example:end -->

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

`tickets statistics snapshot` computes metrics from the current ticket corpus and appends the results as a timestamped record to `.tickets/statistics.yaml`, enabling trend analysis over time.

### CLI Interface

<!-- cli_statistics_help:start -->
```
$ tickets statistics --help

Usage: tickets statistics snapshot [options]

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```
<!-- cli_statistics_help:end -->

Running `tickets statistics` without `snapshot` prints usage and exits.

### Metrics Computed

- **Total tickets** — count of all `.md` files in `.tickets/`.
- **Count by status** — breakdown for each status: Backlog, Ready, In Progress, Complete, Duplicate, Won't Fix.
- **Todo count** — tickets in Backlog, Ready, or In Progress.
- **Done count** — tickets in Complete, Duplicate, or Won't Fix.

If the tickets directory is empty (no `.md` files), all counts are zero and a snapshot is still recorded.

### Stdout Format

<!-- cli_statistics_example:start -->
```bash
$ tickets statistics snapshot

ts: 2026-01-01T00:00:00Z
total: 6
status:
  backlog: 1
  ready: 1
  inprogress: 1
  complete: 1
  duplicate: 1
  wontfix: 1
groups:
  todo: 3
  done: 3
```

Metrics are printed to stdout as key-value pairs:

```
ts: 2026-01-01T00:00:00Z
total: 6
status:
  backlog: 1
  ready: 1
  inprogress: 1
  complete: 1
  duplicate: 1
  wontfix: 1
groups:
  todo: 3
  done: 3
```
<!-- cli_statistics_example:end -->

The file is append-only; existing records are never modified. If `.tickets/statistics.yaml` does not exist, it is created. The `list` and `validate` subcommands ignore `statistics.yaml` (it does not match the ticket filename convention).

## CI/CD

The project uses GitHub Actions for continuous delivery. Two workflows live under `.github/workflows/`.

### publish-npm.yaml — npm Package

Publishes `@polycloudinc/ticketscli` to npmjs.org when changes are pushed to `master` on paths `polycloud-tickets-cli/**`, `.github/workflows/publish-npm.yaml`, or `version`. Also supports manual dispatch via `workflow_dispatch`.

| Setting | Value |
|---|---|
| Runner | `ubuntu-latest` |
| Permissions | `contents: read`, `variables: write` |
| Node version | 20 |
| npm registry | `https://registry.npmjs.org` |
| Modver package | `@polycloudinc/modver` |

**Steps**: checkout → setup Node.js → npm auth (`NPM_TOKEN` secret) → increment `VERSION_BUILD` via `gh variable` → render version with modver → `npm publish`

### publish-apm.yaml — APM Agent Skills

Publishes the APM agent skills package and pushes a git tag when changes are pushed to `master` on paths `apm.yml`, `.apm/**`, `.github/workflows/publish-apm.yaml`, or `version`. Also supports `workflow_dispatch`.

| Setting | Value |
|---|---|
| Runner | `ubuntu-latest` |
| Permissions | `contents: write`, `variables: write` |
| Node version | 22 |

**Steps**: checkout → setup Node.js → increment `VERSION_BUILD` via `gh variable` → compute semver tag with modver → push tag

### Required Secrets and Variables

The following must be configured in the GitHub repository (`polycloudinc/ticketscli`):

| Name | Type | Purpose |
|---|---|---|
| `NPM_TOKEN` | Secret | npmjs.org automation token for publishing `@polycloudinc/ticketscli` |
| `VERSION_BUILD` | Variable | Build number, seeded with initial value (e.g., `0`) before the first workflow run; auto-incremented by both workflows |

Both workflows use `gh variable` (the GitHub CLI) to read and increment `VERSION_BUILD`, which requires the `variables: write` permission on the workflow job. The `${{ github.token }}` is used to authenticate `gh` commands.

### Manual Dispatch

Both workflows can be triggered manually from the GitHub Actions UI via `workflow_dispatch`. On manual dispatch, neither workflow checks path filters — they run unconditionally on the selected branch.

## Agent Skills

The following agent skills are available to assist with ticket workflows:

| Skill              | Description                                                                 | Invoked When                                                                   |
|--------------------|-----------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `tickets-init`          | Initializes the tickets system in a new project using the `tickets init` CLI subcommand. Supports `--code-prefix` flag or interactive prompt. | User asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure. |
| `tickets-create`        | Creates a new ticket from the template with auto-assigned code. Extracts a name from the user's message and uses the `tickets create` subcommand. | User asks to create a new ticket.                                               |
| `tickets-list`          | Lists tickets from `.tickets/` with optional filtering by group, status, or a numeric limit (e.g., "top 5", "first 10").  | User asks to list or show tickets.                                             |
| `tickets-review`        | Reviews a ticket against the current state of the codebase for issues. Also accepts "review next ticket" to automatically locate and review the highest-ranked upcoming ticket.   | User asks to review a ticket or says "review next ticket".                     |
| `tickets-execution-plan`| Creates and manages checkbox-based execution plans with optional phasing.   | User asks to create, update, or check off execution plan items in a ticket.    |
| `tickets-transition`    | Transitions a ticket between statuses using the `tickets transition` CLI.  | User asks to transition, move, or change the status of a ticket.               |
| `tickets-rank`          | Adjusts ticket priority with the `tickets rank` CLI subcommands (`up`, `down`, `first`, `last`). | User asks to promote, demote, reorder, or change the rank of a ticket.         |

### Execution Plan Phasing

The `tickets-execution-plan` skill splits tasks into named phases (each a level-three heading) when:

- The total number of tasks exceeds **5**, or
- Tasks touch **logically different parts of the system** that can be completed and tested individually.

Otherwise, tasks remain as a flat linear checkbox list under a single `# Execution Plan` heading.
