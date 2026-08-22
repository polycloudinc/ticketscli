# Introduction

The **ticketscli** project lets you plan out your project and track delivery using a terminal-based CLI and also using [agent skills](https://agentskills.io/) with your tickets tracked in Git rather than an external tool.

With **ticketscli** you can:
- Plan your project and track execution
- Capture your complete backlog in Git
- Track code changes and backlog changes together in the same commits where appropriate
- Implement spec-driven development (SDD) using tickets as the central context for your coding agent

We have personally used this system to deliver work with
- [GitHub Copilot](https://github.com/copilot) with Claude Opus 4.5 through 4.8 and with GPT 5.6 Sol
- [OpenCode](https://opencode.ai/) with Claude Sonnet 4.5, DeepSeek V4 Pro, DeepSeek V4 Flash, Kimi K3 and with GPT 5.6 Luna

# Demo / Quick Start

TODO

# Who is this for?

ticketscli is intended for people and teams that:
- Consider tickets / issues to be an integral part of the definition and documentation of a project and want them to be tracked in lockstep with the code, rather than in a separate database.
- Want to be able to `git blame` on tickets.
- Want the tickets including "Won't Fix" items to be available for coding agents to use as context without making MCP or other tool calls.

It's probably not a good fit for those that:
- Have existing workflow automations that are driven off issue events and content, for example using GitHub Actions.
- Have a philosophical objection to having entries like "Backlog grooming" that contain only ticket changes in the commit history.
- Like the rich work planning UI's and visualizations offered by the aforementioned tools
- Have non-technical team members who would not be comfortable with using a CLI or coding agent for working with tickets.

# Tickets

A ticket represents a feature, a bug fix, it some other piece of work to be done on your project.  Other work planning systems use different names for these - for example [JIRA](https://www.atlassian.com/agile/tutorials/issues) and [GitHub](https://github.com/features/issues) calls these "Issues" and [Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/boards/work-items/about-work-items?view=azure-devops&tabs=agile-process) calls them "Work Items".

In **ticketscli**, a ticket is simply a [Markdown](https://daringfireball.net/projects/markdown/) file created from our template and stored in the `.tickets/` directory in your project.  A ticket has a code which is it's referenceable identity, and a name.  Ticket files are named with the following pattern:

```
<code> - <name>.md
```

For example: `TIK001 - List Subcommand.md`

The code and name are stored in the ticket file as YAML front matter along with other attributes.  The structure of a ticket is defined by the following template which is embedded in ticketscli:

<!-- misc_template:start -->
```markdown
---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code:
ticket_name:
ticket_status:
ticket_priority:
ticket_rank:
ticket_created:
ticket_updated:
ticket_completed:
---
```
<!-- misc_template:end -->

The `api` key identifies the front matter schema version.  All tickets must declare `api: polycloudinc/ticketscli/v1`; commands other than `tickets migrate` halt with an error when a ticket is not declared as such.

A ticket's status is stored as a lowercase code with no spaces:
- `backlog`
- `ready`
- `inprogress`
- `complete`
- `duplicate`
- `wontfix`

Status codes map to display names as follows:

| Code | Display name |
| --- | --- |
| `backlog` | Backlog |
| `ready` | Ready |
| `inprogress` | In Progress |
| `complete` | Complete |
| `duplicate` | Duplicate |
| `wontfix` | Won't Fix |

At the moment there is no state machine to govern transitions, and any status may transition to any other status.  This might be changed in the future.

The body of the ticket has the following sections:
- **Introduction** - typically a one-liner stating the purpose of the ticket.
- **Requirements** - the requirements in business or outcome terms without dictating technical solution.
- **Technical Solution** - the solution design with the specific technical choices that have been made.
- **Execution Plan** - a flat linear list of tasks, broken into logical phases, with verification steps that must pass before exiting each phase.

The ticketscli project itself is managed with ticketscli, and you can browse it's backlog for examples of real tickets: https://github.com/polycloudinc/ticketscli/tree/master/.tickets

# Workflow

Regardless of whether you are interacting with ticketscli directly via it's CLI or through the provided agent skills, the general workflow is similar to what you would be used to from other tools:

- Create a ticket to represent a new feature, bug fix, etc.  The new ticket is created in _Backlog_ status.
- Elaborate the ticket, fleshing out the requirements, making technical choices and ultimately rendering down an execution plan with verification steps for the delivery of the work represented by the ticket.
- For most projects there's some kind of overarching prioritization or backlog grooming cadence that maintains a roadmap or a delivery plan based on what features are the most important and also which are actually ready to work on.
- Eventually our feature ticket is fully fleshed out and we mark it as _Ready_.  Thereafter it is ranked / prioritized to be executed.
- Once work starts it's status is changed to _In Progress_ and the feature is delivered and verified according to the execution plan.
- When fully delivered the ticket status is changed to _Complete_.

# Command-Line Interface (CLI)

## Introduction

The CLI is the primary way of working with ticketscli, and you can fully manage your project backlog and roadmap via CLI and your preferred text editor.

Below, we walk through the subcommands offered by the CLI in logical order.

## Tickets Directory Resolution

The CLI resolves the tickets directory on every invocation:

| Condition | Behavior |
|---|---|
| `--tickets-dir` / `-d` flag provided | Uses the given path (no resolution) |
| `.tickets/` exists, `_tickets/` does not | Uses `.tickets/` (silent) |
| `_tickets/` exists, `.tickets/` does not | Uses `_tickets/` and prints a deprecation warning to stderr: `Warning: _tickets is deprecated. Rename the directory to .tickets to migrate.` |
| Both exist | Error: `Error: both .tickets and _tickets directories exist. Remove one or use --tickets-dir.` |
| Neither exists | Defaults to `.tickets/` |

## init

The `init` command initializes the tickets system, setting up the `.tickets/` directory and it's `settings.yaml` configuration file.  You only need to `init` a project once and if you accidentally try to re-initialize a project the command will refuse to avoid unintended changes.

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

Example usage when starting a new project:

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

Resultant `settings.yaml` file in the `.tickets/` directory:

```yaml
code_prefix: MYP
```
<!-- cli_init_example:end -->

For information about the file `statistics.yaml` see the `statistics` command, below.

## create

The `create` command creates a new ticket.  It generates the ticket from the built-in template and injects values into the ticket's YAML front matter.

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
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: MYP001
ticket_name: Add database connection pool to service
ticket_status: backlog
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

The `list` command let's you list some or all of the tickets in your project.

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

TODO clean up the status discussion and flag discussion

The `ticket_status` field stores one of the following lowercase codes:

| Status (`ticket_status` value) | Display name      | Filter Group      |
| ------------------------------ | ----------------- | ----------------- |
| `backlog`                      | Backlog           | `--group backlog` |
| `ready`                        | Ready             | `--group active`  |
| `inprogress`                   | In Progress       | `--group active`  |
| `complete`                     | Complete          | `--group done`    |
| `duplicate`                    | Duplicate         | `--group done`    |
| `wontfix`                      | Won't Fix         | `--group done`    |

The `--group todo` filter returns tickets from both `--group backlog` and `--group active` (i.e., `backlog`, `ready`, `inprogress`), sorted by rank.

## CLI Filters

| Flag                     | Short | Matches                                   |
|--------------------------|-------|-------------------------------------------|
| `--group backlog`        | `-g`  | `backlog`                                 |
| `--group active`         | `-g`  | `ready`, `inprogress`                     |
| `--group done`           | `-g`  | `complete`, `duplicate`, `wontfix`        |
| `--group todo`           | `-g`  | `backlog`, `ready`, `inprogress`          |
| `--status <value>`       | `-s`  | Tickets whose `ticket_status` matches the given value. Valid values (case-insensitive, single-word): `backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`. |
| `--limit <N>`            | `-l`  | Limits output to the first N tickets after filtering and sorting. `N` must be a positive integer >= 1. If the limit exceeds the number of matching tickets, all are displayed.

Only one filter (`--group` or `--status`) may be specified at a time. `--limit` is not a filter and may be combined with `--group` or `--status`.

### List Table Output

TODO simplify the discussion of column width to a single paragraph explanation and an example invocation with a custom width.

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

TODO find a better example of a substring or if there is none, drop the point.

- An exact match takes priority over substring matching (e.g. `--group backlog` matches even though `backlog` is also a substring of… itself)
- If the input is ambiguous (matches multiple values), the command prints an error listing the candidates
- If the input does not match any value, the command prints an error listing all valid values

Example usage:

<!-- cli_list_example:start -->
```bash
$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 ready       
TST001   Alpha Ticket                                             2 backlog     
TST003   Charlie Ticket                                           3 inprogress  
TST004   Delta Ticket                                             - complete    
TST005   Echo Ticket                                              - duplicate   
TST006   Foxtrot Ticket                                           - wontfix     
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets list --status complete

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST004   Delta Ticket                                             - complete    
-------- ---------------------------------------------------- ----- ------------
1 matching from 6 total tickets
```
<!-- cli_list_example:end -->

## rank

The `rank` command let's you change the planned execution order of your backlog.  `rank` has four subcommands of it's own:
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
TST002   Bravo Ticket                                             1 ready       
TST001   Alpha Ticket                                             2 backlog     
TST003   Charlie Ticket                                           3 inprogress  
TST004   Delta Ticket                                             - complete    
TST005   Echo Ticket                                              - duplicate   
TST006   Foxtrot Ticket                                           - wontfix     
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
TST003   Charlie Ticket                                           1 inprogress  
TST001   Alpha Ticket                                             2 backlog     
TST002   Bravo Ticket                                             3 ready       
TST004   Delta Ticket                                             - complete    
TST005   Echo Ticket                                              - duplicate   
TST006   Foxtrot Ticket                                           - wontfix     
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets
```
<!-- cli_rank_example:end -->

## transition

The `transition` command manages the process of transitioning a ticket from one status to another.

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
TST002   Bravo Ticket                                             1 ready       
TST001   Alpha Ticket                                             2 backlog     
TST003   Charlie Ticket                                           3 inprogress  
TST004   Delta Ticket                                             - complete    
TST005   Echo Ticket                                              - duplicate   
TST006   Foxtrot Ticket                                           - wontfix     
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition --ticket TST001 --target inprogress

Transitioned TST001 to 'inprogress'.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 ready       
TST001   Alpha Ticket                                             2 inprogress  
TST003   Charlie Ticket                                           3 inprogress  
TST004   Delta Ticket                                             - complete    
TST005   Echo Ticket                                              - duplicate   
TST006   Foxtrot Ticket                                           - wontfix     
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets

$ tickets transition -t TST001 -T complete

Transitioned TST001 to 'complete'.

$ tickets list

Code     Subject                                               Rank Status      
-------- ---------------------------------------------------- ----- ------------
TST002   Bravo Ticket                                             1 ready       
TST003   Charlie Ticket                                           2 inprogress  
TST001   Alpha Ticket                                             - complete    
TST004   Delta Ticket                                             - complete    
TST005   Echo Ticket                                              - duplicate   
TST006   Foxtrot Ticket                                           - wontfix     
-------- ---------------------------------------------------- ----- ------------
6 matching from 6 total tickets
```

Transitioned ticket file:

```markdown
---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TST001
ticket_name: Alpha Ticket
ticket_status: complete
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
```bash
$ tickets validate --help

Usage: tickets validate [--all | --ticket <code>] [options]

Options:
  -a, --all                 Validate all tickets
  -t, --ticket <code>       Validate a single ticket by code
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
```
<!-- cli_validate_help:end -->

The command checks three categories of deviations:

1. **Missing fields** — fields in the template but absent from the ticket
2. **Unknown fields** — fields in the ticket but not in the template
3. **Invalid values** — hardcoded constraints for specific fields

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

This capability is still a work in progress and it currently provides a snapshot subcommand that records the point in time metrics regarding your tickets to `.tickets/statistics.yaml`.  We will add reporting and visualization of these stats in the future.

<!-- cli_statistics_snapshot_help:start -->
```bash
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

As mentioned our CLI distribution is a bit rough right now and cleaning that up is at the top of our roadmap.

The CLI is a Bash script, with a Python dependency, distributed via npm.  For more details on why this is the case see Implementation Notes, below.

TODO document how to install the prerequisites and the CLI via npx

# Agent Skills

## Introduction

ticketscli includes a set of agent skills that guide your coding agent on how to use the CLI and to assist you throughout the planning and delivery workflow.

## Overview

We provide several skills, some of which are convenience skills thst simply translate natural language to a CLI invocation, and others which leverage the capabilities of the coding agent to help with planning, reviewing and executing work.

- tickets-init
- tickets-create
- tickets-list
- tickets-review
- tickets-execution-plan
- tickets-transition
- tickets-rank

## tickets-init Skill

The `tickets-init` skill is a convenience skill that wraps the `tickets init` CLI command.

Example usage:

```Prompt
Initialize the tickets system with the code TIK
```

## tickets-create Skill

The `tickets-create` skill uses the `tickets create` CLI command to create a new ticket, then uses the abilities of the coding agent to begin filling out the Introduction and Requirements sections based on your initial prompt.

After triggering this skill you will likely iterate with the coding agent to flesh out the Requirements and Technical Solution before using the `tickets-execution-plan` skill to define the execution plan.

Example usage - initial ticket creation:

```Prompt
Create a ticket for porting the tickets CLI from bash to Rust
```

Follow up prompts to flesh out the requirements and solution:

```Prompt
The functional correctness of Rust ported CLI can be verified using the existing test suite.  All tests should pass.
```

## tickets-list Skill

The `tickets-list` skill is a convenience skill that uses the `tickets list` CLI to list tickets.

Example usage:

```Prompt
Show me all tickets in the backlog

→ Skill "tickets-list"
$ ./tickets.sh list --group backlog
```

Or:

```Prompt
What is our WIP

→ Skill "tickets-list"
$ ./tickets.sh list --status inprogress
```

## tickets-review Skill

The `tickets-review` skill uses the capabilities of the coding agent to review the ticket for completeness and readiness.  Where it identifies issues it presents them as a numbered list so that you can respond and guide the agent on how to address each point with further updates to the ticket.

Example usage:

```Prompt
Review the ticket
```

Or:

```Prompt
Review ticket TIK033
```

Or even:

```Prompt
let's work on it TIK054.  review it

+ Thought: 304ms
→ Skill "tickets-review"
✱ Glob ".tickets/TIK054*"
$ ls .tickets/ | grep -i TIK054

  TIK054 - Revise Ticket Front Matter.md
```

## tickets-execution-plan Skill

The `tickets-execution-plan` skill uses the coding agent to review the Requirements and Technical Solution in the ticket and propose an execution plan for delivery.

Execution plans are a linear set of tasks that should be performed in sequence.

Execution plans also intentionally break the tasks up into phases of at most 5 tasks, and for each phase, at least two verification steps are defined.

Most of the time, after you have iterated the Requirements and Technical Solution to your satisfaction with the coding agent, the simple prompt:

```Prompt
Define the execution plan
```

Will yield a good plan.  You should review the plan before letting the agent execute it.  If you see anything that needs fixing you can prompt the agent further to make those corrections 

## tickets-transition Skill

The `tickets-transition` skill is a lightweight convenience skill for invoking the `tickets transition` CLI command.

You might use it by telling the agent to transition s specific skill:

```Prompt
Mark ticket TIK055 as done
```

Or if you have been working on a ticket with the agent then simply:

```Prompt
Move this ticket to complete
```

You can also specify multiple tickets and the agent will invoke the CLI for each:

```Prompt
Update TIK055, TIK056 and 42 through 45 to done
```

The skill is flexible around the phrasing you use and "transition", "mark", "move" and other verbs will normally successfully trigger the skill.

## tickets-rank Skill

The `tickets-rank` skill is a convenience skill over the four ranking `tickets` CLI subcommands `rank first`, `rank last`, `rank up` and `rank down`.

You can describe the ranking operation you want to perform and the agent will resolve your intent to the appropriate CLI invocation(s).  For example:

```Prompt
Move this ticket to the top of the backlog
```

Or:

```Prompt
Move TIK043 down three slots.
```

## Installing the Agent Skills

### Installing via Agent Package Manager (APM)

We support [Agent Package Manager](https://microsoft.github.io/apm/) for distributing the ticketscli agent skills.  

To install via Agent Package Manager you must first [install the APM CLI](https://microsoft.github.io/apm/#install-apm).

```bash
apm install https://github.com/polycloudinc/ticketscli.git --dev --target <your coding agent>
```

The `--dev` switch marks `ticketscli` as a dev dependency - this is only important if your project itself publishes an APM package so that ticketscli does not become a runtime dependency of your project.

See the APM docs for the list of [valid target values](https://microsoft.github.io/apm/reference/cli/install/#target-selection).  For example to install for use with [OpenCode](https://opencode.ai/):

```bash
apm install https://github.com/polycloudinc/ticketscli.git --dev --target opencode
```

### Installing via Vercel skills.sh

Adding parallel support for distribution via Vercel skills.sh is in our roadmap — see [TIK065 - Add Vercel Skills Sh Distribution Channel](.tickets/TIK065%20-%20Add%20Vercel%20Skills%20Sh%20Distribution%20Channel.md).

# Feature Roadmap

The highest priority right now is to rewrite the CLI on Rust.  It is currently just a big Bash script which was really just a proof-of-concept.  While it is fully functional, it had some rough edges around distribution (through npm) and Python dependencies for front matter processing.  These rough edges add adoption friction.

Once the Rust rewrite is done and the distribution is smoother, there are quite a number of features planned to help with planning and executing work.

The backlog is as follows:

```
TODO
```

## Prerequisites

TODO merge this into the CLI installation section 

The CLI requires **Python 3** and the **PyYAML** library. YAML operations are handled by a bundled Python helper script (`yz.py`) instead of an external `yq` binary.

```bash
# Install dependencies
pip install pyyaml

# Verify
python3 -c "import yaml; print(yaml.__version__)"
tickets validate --all   # should pass without errors
```

# Implementation Notes

## Ticket Template Resolution

The ticket template is always resolved from the directory where `tickets.sh` resides (`$(dirname "$(readlink -f "$0")")/Ticket.md`). Both `tickets create` and `tickets validate` locate the template alongside the script itself. The `tickets init` subcommand no longer copies the template into the project directory.

## yz.py

### Introduction

`tickets.sh` is a bash script that delegates all YAML operations to a bundled Python helper (`yz.py`) using PyYAML. The helper is located alongside `tickets.sh` in the npm package and handles both front matter manipulation in Markdown files and plain YAML file operations.

The CLI originally used ad-hoc `sed`/`grep` pipelines for front matter manipulation, which were fragile. We consolidated everything onto `yq` — and promptly ran into the fact that there are two completely unrelated projects sharing that name:

- [mikefarah/yq](https://github.com/mikefarah/yq) — a standalone Go binary with its own expression language and native Markdown front matter support (`--front-matter extract`/`process`). This is the one we standardized on first, but distributing a system-level Go binary alongside an npm package is awkward, requiring a separate download and install step.
- [kislyuk/yq](https://github.com/kislyuk/yq) — a Python package, but merely a thin wrapper around the `jq` binary: it requires `jq` to be installed and has no front matter support at all, so it was never a viable alternative.

The name collision alone causes real confusion — any instruction to "install yq" is ambiguous, and scripts written for one project fail against the other. And even when the right project is installed, depending on an externally provided `yq` exposes us to potential conflicts with whatever version the user happens to have on their system. We avoid these conflicts entirely by creating our own script: `yz.py`, a small helper bundled directly in the npm package that uses PyYAML for all YAML operations — front matter reads and writes in Markdown tickets, and plain YAML reads and writes for `settings.yaml` and `statistics.yaml`. The only dependencies are `python3` and `pyyaml`, and no system-level `yq` or `jq` binary is required. The Python dependency is a shim that gives us consistent processing of YAML front matter.

`yz.py` is an interim solution: it will be retired, along with the Python dependency, when the CLI is rewritten in Rust — see [TIK021 - Rewrite CLI in Rust](.tickets/TIK021%20-%20Rewrite%20CLI%20in%20Rust.md).

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

TODO verify the following statement against the actual code

Writing front matter from scratch (e.g. in `cmd_create`) uses `printf`, not yq, since there is no existing YAML to manipulate.
