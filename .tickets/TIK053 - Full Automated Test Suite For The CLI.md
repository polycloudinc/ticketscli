---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK053
ticket_name: Full Automated Test Suite For The CLI
ticket_status: complete
ticket_priority: Medium
ticket_rank:
ticket_created: "2026-08-15T09:36:45Z"
ticket_updated: "2026-08-15T14:24:30Z"
ticket_completed: "2026-08-15T14:24:25Z"
---
# Introduction

The tickets CLI currently has no automated test coverage, so regressions in subcommand behavior are only caught manually. This ticket establishes a full automated test suite that exercises every CLI subcommand so changes can be made with confidence. A key purpose of the suite is to verify the functional correctness of the Rust CLI rewrite planned in TIK021 (Rewrite CLI in Rust), so it must characterize the current CLI's observable behavior in a way a replacement implementation can be tested against.

# Requirements

- Automated tests cover all CLI subcommands: `init`, `list`, `validate`, `create`, `transition`, `rank` (including `up`, `down`, `first`, `last`, and normalization), and `statistics snapshot`
- Tests cover the `list` subcommand's filtering options (`--group`, `--status`, `--limit`) and its output formatting, including the summary line
- Tests cover error handling paths: invalid options, missing required arguments, ambiguous or unknown status/group values, and missing tickets directories
- Tests cover front matter behavior: rank normalization, timestamp updates (`ticket_created`, `ticket_updated`, `ticket_completed`), and status transitions
- The test suite runs non-interactively with a single command and requires no manual setup of fixture data beyond what the suite itself creates
- The test suite runs in isolation against temporary tickets directories without touching real ticket data
- Tests exercise the CLI through its external interface (arguments, stdin/stdout/stderr, exit codes, and file system effects) rather than implementation internals, so the same suite can run against the Rust rewrite from TIK021 to verify functional equivalence
- The test suite can be pointed at a configurable CLI executable, allowing it to run against both the current Bash implementation and the future Rust implementation
- The test suite can be run in CI so failures block merging

# Technical Solution

The test suite lives under a `test/` directory in the project root and is organized into three parts: fixtures, test cases, and test executions.

**Fixtures** (`test/fixtures/`): Fixtures represent different project states (e.g., an empty tickets directory, a populated tickets directory with tickets in various statuses and ranks) that test cases use as their starting state. Each fixture is tracked in its own subdirectory named `fxxx_short_fixture_name` (a sequential three-digit fixture code followed by a short descriptive name). A fixture may be used by more than one test case, so fixtures must be treated as read-only by test cases — each execution copies the fixture into its execution directory rather than mutating it in place. Each test case uses exactly one fixture; fixtures are never combined within a single test case, to keep tests easy to understand and debug.

**Test cases** (`test/cases/`): Each test case is implemented as an individual Bash script named `tcxxx_short_test_name.sh` (a sequential three-digit test case code followed by a short descriptive name). A test case script is not executed directly; instead it is sourced by the test executor and exposes a two-function interface:

- `fixture` — returns (echoes) the code of the fixture the test case requires, e.g. `f123`. The executor calls this to learn which fixture to copy into the execution directory.
- `run` — executes the test inside the prepared execution directory: it invokes the CLI under test and performs its own assertions (assertions are the responsibility of the test case itself; there is no shared assertion library). It returns an outcome via its exit status (0 = pass, non-zero = fail) and echoes a short informative message describing the result, which the executor captures for its log.

**Test executions** (`test/executions/`): Every run of a test case is performed in a fresh execution directory under `test/executions/`, named `tcxxx_yyyy-MM-ddTHH-mm-ssZ` — the three-digit test case code followed by an ISO 8601 UTC timestamp. This keeps runs isolated and preserves artifacts from past runs for debugging. The `test/executions/` directory contains a `.gitignore` file that ignores the execution directories so they are never committed.

**Test executor** (`test.sh`): A `test.sh` script in the project root provides its own CLI with subcommands for running the suite. Its `exec` subcommand takes:

- `--cases` — either a comma-separated list of test case codes (e.g., `--cases tc001,tc005,tc655`) or `all` to execute every test case.
- `--cli` — path to the CLI executable under test, defaulting to the repo's Bash implementation (`tickets.sh`). This allows the same suite to run against the future Rust implementation. The path is passed through to test cases (e.g., via an exported environment variable) so every case invokes the CLI under test uniformly.

For each selected test case, the executor: sources the case script; calls its `fixture` function to learn the required fixture code; creates the fresh execution directory under `test/executions/`; copies that fixture into it; and calls the case's `run` function inside the execution directory, capturing its exit status and message. The executor logs to stdout each test as it runs along with its pass/fail status and the case's informative message, then prints an aggregated summary at the end. The executor exits non-zero if any selected test case fails, so it can gate CI.

# Execution Plan

## Phase 1: Test Executor and Harness

### Tasks
- [x] Create the `test/` directory structure: `test/cases/`, `test/fixtures/`, `test/executions/`
- [x] Add a `.gitignore` in `test/executions/` that ignores the timestamped execution directories
- [x] Implement `test.sh` in the project root with subcommand parsing and an `exec` subcommand accepting `--cases` (comma-separated case codes or `all`) and `--cli` (default: the repo's `tickets.sh`)
- [x] Implement the per-case execution flow: source the case script, call its `fixture` function, create the `tcxxx_yyyy-MM-ddTHH-mm-ssZ` execution directory, copy the fixture into it, call the case's `run` function, capture its exit status and message
- [x] Implement stdout logging of each test as it runs (pass/fail status plus the case's message), a final aggregated summary, and a non-zero exit when any case fails
- [x] Reject unknown case codes, duplicates, and mixing `all` with explicit codes with an error
- [x] Create the reference fixture `f001_no_tickets_dir` (a project with no tickets directory) and the reference test case `tc001_init_creates_tickets_dir.sh` implementing the `fixture`/`run` interface, proving the harness end to end

### Verification Steps
- [x] Run `./test.sh exec --cases tc001` and confirm it passes, logs the case result, and leaves a populated execution directory under `test/executions/`
- [x] Run `./test.sh exec --cases tc999` and confirm a clear error and non-zero exit
- [x] Run `git status --porcelain` after executions and confirm no execution directories appear (`.gitignore` works)

## Phase 2: Fixture Library

### Tasks
- [x] Create fixture `f002_empty_tickets_dir` (initialized tickets directory with `settings.yaml` and `statistics.yaml`, zero tickets)
- [x] Create fixture `f003_mixed_status_tickets` (tickets spanning all six statuses with varied ranks, priorities, and timestamps, front matter conforming to the `Ticket.md` template)
- [x] Confirm all fixtures are tracked in git and follow the `fxxx_short_fixture_name` naming convention

### Verification Steps
- [x] Run `./tickets.sh validate --all --tickets-dir test/fixtures/f003_mixed_status_tickets/.tickets` and confirm no deviations; confirm `f002_empty_tickets_dir` behaves as an initialized empty tickets directory (`list` reports `0 matching from 0 total tickets`; `validate --all` reports "no tickets found", which is the CLI's designed behavior for an empty directory)
- [x] Run `./test.sh exec --cases all` and confirm the suite is still green

## Phase 3: Test Cases for Create, List, and Validate

### Tasks
- [x] Implement `tc002_create_assigns_defaults.sh`: new ticket gets the next sequential code, `[[Backlog]]` status, Medium priority, next rank, and created/updated timestamps
- [x] Implement `tc003_list_table_output.sh`: table columns, ascending rank sort, `-` rank for done tickets, truncated long subjects, and the `N matching from M total tickets` summary line
- [x] Implement `tc004_list_filter_options.sh`: `--group` (backlog/active/done/todo), `--status` (exact and fuzzy substring, ambiguity errors), `--limit`, and rejection of multiple filters
- [x] Implement `tc005_validate_schema.sh`: valid tickets pass; tampered front matter (missing fields, unknown fields, invalid status/priority/rank/code/aliases/timestamps) is reported

### Verification Steps
- [x] Run `./test.sh exec --cases tc002,tc003,tc004,tc005` and confirm all pass
- [x] Run `./test.sh exec --cases all` and confirm the full suite is green

## Phase 4: Test Cases for Transition, Rank, and Statistics

### Tasks
- [x] Implement `tc006_transition_lifecycle.sh`: status transitions across the lifecycle, `ticket_completed` set and rank cleared on completion, `ticket_completed` removed and rank appended on reopening, `ticket_updated` touched, fuzzy/ambiguous target handling
- [x] Implement `tc007_rank_operations.sh`: `rank up`/`down` swaps, `rank first`/`last` shifts, rank normalization of gaps, done tickets excluded from ranking
- [x] Implement `tc008_statistics_snapshot.sh`: snapshot appended to `statistics.yaml` with correct per-status counts and todo/done group totals

### Verification Steps
- [x] Run `./test.sh exec --cases tc006,tc007,tc008` and confirm all pass
- [x] Run `./test.sh exec --cases all` and confirm the full suite is green

## Phase 5: Error Handling and CLI Configurability

### Tasks
- [x] Implement `tc009_cli_error_handling.sh`: unknown subcommand/option, missing required arguments (`--name`, `--ticket`, `--target`), and ambiguous or unknown status/group values all fail with non-zero exit and an error message
- [x] Implement `tc010_tickets_dir_resolution.sh`: both `.tickets` and `_tickets` present is an error, `_tickets` alone emits the deprecation warning, neither defaults to `.tickets`, and `--tickets-dir` overrides
- [x] Verify the `--cli` switch end to end by running the suite with an explicit path to the CLI executable

### Verification Steps
- [x] Run `./test.sh exec --cases all` and confirm the full suite is green
- [x] Run `./test.sh exec --cases all --cli "$(pwd)/tickets.sh"` and confirm the full suite is green via the `--cli` switch

## Phase 6: Documentation and CI

### Tasks
- [x] Document the test suite in `Tickets System.md`: directory layout, fixture/case naming conventions, the `fixture`/`run` case interface, and how to run the suite
- [x] Add a GitHub Actions workflow that runs `./test.sh exec --cases all` on push and pull request so failures block merging

### Verification Steps
- [x] Run the exact CI command locally (`./test.sh exec --cases all`) and confirm exit code 0
- [x] Confirm the workflow file is valid YAML and references the same command
