---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK062
aliases:
- TIK062
name: Script CLI Example Usage Capture
ticket_status: '[[In Progress]]'
ticket_priority: Medium
ticket_rank: 18
ticket_created: '2026-08-16T05:15:08Z'
ticket_completed:
ticket_updated: '2026-08-16T05:45:55Z'
---
# Introduction

The CLI documentation in `Tickets System.md` is populated with hand-written example usage blocks (bare `bash` code fences showing commands and, occasionally, resultant files). These drift out of sync with the real CLI behavior as flags and defaults change, and one block is still an unpopulated `TODO`. Provide a mechanism that scripts the execution of example CLI commands and embeds the captured output (transcripts and resultant files) into the CLI documentation sections, keeping every example accurate without manual transcription.

# Requirements

- The mechanism must script each embedding as a discrete script in a new `test/examples/` directory, one per embedding, with short names such as `cli_list_help.sh` and `cli_list_example.sh`; the script's basename (minus `.sh`) is the embedding identifier used in the HTML comment pair that demarcates the embedding in the documentation (`<!-- <id>:start -->` / `<!-- <id>:end -->`)
- The existing `cli_*` subcommand help-text embeddings must be ported to `cli_*_help.sh` scripts (`cli_list` becomes `cli_list_help`, and so on for `init`, `create`, `validate`, `transition`, `statistics`, and the four `rank` variants); the `cli_*_example.sh` scripts are yet to be defined and will follow the usage sections of the documentation (init walkthrough, init flag variants, create, validate, list, rank, transition, statistics)
- The example scripts must be sourced rather than executed, using the same interface contract and fixture mechanics as the test cases (e.g. a `fixture()`-style function naming a fixture from `test/fixtures/` and a `run()`-style body emitting the transcript), running with the live CLI available (e.g. a `$TICKETS_CLI`-style variable); like test cases they consume fixtures, but they are managed by `doc_update.sh` — `test.sh` neither sources them nor treats them as `tc*` cases
- Each example script may return the name of a file (relative to its execution directory) whose contents should be embedded following the example's invocation transcript, to show the result of the commands (e.g. the created ticket file for `create`, `settings.yaml` for the `init` walkthrough); `result_file()` may return nothing, in which case no result block is embedded
- Each example script may also define post-processing steps applied to the result file content immediately before it is embedded (e.g. replacing the ticket template's long `TODO: ...` instruction paragraphs with a simple `TODO` in the `create` result); the transform receives the content on stdin and emits the transformed content on stdout
- Each example script may also return a short description paragraph (e.g. a `result_description()`-style function echoing prose such as "Resultant ticket file:") that appears after the example usage transcript and before the example result, matching the content style already present in the existing documentation
- Some examples must be able to capture the stdout of a command to a file and use that file as the result file (e.g. the `statistics` metrics output captured to a file and embedded as the result block)
- The mechanically embedded content replaces only what sits between the marker pair (transcript in a fenced block, optionally followed by the description paragraph and the returned result file's contents in its own fenced block), leaving hand-written surrounding prose untouched
- The mechanism must cover the documented usage of every subcommand: `init` (interactive walkthrough plus flag variants), `create` (including the resultant ticket file), `validate`, `list` (including the currently unpopulated `Example usage` TODO block), `rank` (normalize plus the `up`/`down`/`first`/`last` mutations), `transition`, and `statistics`
- Captured output must be deterministic: variable content such as generated timestamps must be normalized to a fixed placeholder before embedding, so re-running the mechanism produces no diff (idempotency)
- The mechanism must report (warn about) markers without a corresponding example script and scripts without a corresponding marker pair, so typos do not silently pass; the run must exit non-zero if no embeddings were found or the target file does not exist
- Once an example or help snapshot is covered by an embedding, no hand-maintained transcript for it may remain in the documentation; it must be possible to audit that every covered block sits between a marker pair
- Drift must be guarded: a case in the test suite (per the existing harness pattern) and the doc auto-update path must run the mechanism so stale examples fail CI and get refreshed automatically, mirroring the existing `doc_update.sh` treatment
- The mechanism must be discoverable and documented (usage, directory conventions, script contract, and the marker convention) in `Tickets System.md`
- The changes extend the existing `doc_update.sh` mechanism established by TIK061 — no separate update script is introduced; the embedding identifier table is derived from the `test/examples/` directory rather than being hardcoded

# Technical Solution

`doc_update.sh` is the single update mechanism. It discovers embeddings by scanning `test/examples/*.sh`: the basename of each script is the embedding identifier it manages. The existing hardcoded identifier table and shell-rendered help capture are replaced by the sourced-script harness.

Script contract (mirroring `test.sh`'s case contract, without `test.sh` participation):

- `fixture()` echoes the code of the fixture the script requires from `test/fixtures/` (existing fixtures are reused where their state fits — e.g. the empty project fixture for `init`/help scripts, a populated ticket set for `list`/`rank`/`transition` — with new fixtures added where the needed state does not exist)
- The script body composes the transcript as its stdout: each command echoed with a `$ ` prefix (preserving the existing inline `# comment` style where present) followed by the command's captured stdout/stderr
- A `result_description()` function may echo a short paragraph (e.g. "Resultant ticket file:") that becomes a line of prose between the transcript and the result block
- A `result_file()` function may echo a path, relative to the execution directory, whose contents are embedded in a fenced block immediately after the description (or after the transcript when there is no description); it may return nothing
- A `result_postprocess()` function, when defined, reads the result file content on stdin and emits the transformed content on stdout; its output is embedded instead of the raw result file content (normalization is applied first)
- For stdout-capture results, the script redirects a command's stdout to a file (e.g. `tickets statistics snapshot > metrics.txt`) and returns that file from `result_file()`, so the captured output itself becomes the embedded result

For each example script, `doc_update.sh` stages the named fixture into a fresh execution directory under `test/executions/` (same mechanics as `test.sh`: copy the `test/fixtures/<fcode>_*` directory contents in, export `$TICKETS_CLI`), sources the script, runs its body with the live CLI available, and captures stdout as the transcript. The fixture staging lives in `doc_update.sh` itself; `test.sh` is never involved in running example scripts. Captured text is piped through normalization that replaces ISO 8601 UTC timestamps with a fixed placeholder so `create`/`transition` transcripts re-run cleanly. The description (if any) and result file contents (if any) are appended. The script then replaces everything between the matching `<!-- <id>:start -->` / `<!-- <id>:end -->` pair in the target file (default `Tickets System.md`, overridable with `--file`), preserving the marker comments. Markers whose id has no script, and scripts whose id has no marker pair, are warned about on stderr without aborting.

Porting the help embeddings: each existing `cli_<subcommand>` embedding becomes a `cli_<subcommand>_help.sh` script whose transcript is `$ tickets <subcommand> --help` followed by the captured help output; the corresponding marker pairs in `Tickets System.md` are renamed `cli_<subcommand>_help`, so every snapshot — help text and usage alike — flows through the same scripted mechanism. Help scripts use the simplest fixture (an initialized project, no tickets required).

Embedding set (id → scenario):

| id | scenario | description | result file |
|----|----------|-------------|-------------|
| `cli_init_help` | `tickets init --help` (port of `cli_init`) | — | — |
| `cli_create_help` | `tickets create --help` (port of `cli_create`) | — | — |
| `cli_list_help` | `tickets list --help` (port of `cli_list`) | — | — |
| `cli_validate_help` | `tickets validate --help` (port of `cli_validate`) | — | — |
| `cli_transition_help` | `tickets transition --help` (port of `cli_transition`) | — | — |
| `cli_statistics_help` | `tickets statistics --help` (port of `cli_statistics`) | — | — |
| `cli_rank_up_help` | `tickets rank up --help` (port of `cli_rank_up`) | — | — |
| `cli_rank_down_help` | `tickets rank down --help` (port of `cli_rank_down`) | — | — |
| `cli_rank_first_help` | `tickets rank first --help` (port of `cli_rank_first`) | — | — |
| `cli_rank_last_help` | `tickets rank last --help` (port of `cli_rank_last`) | — | — |
| `cli_init_example` | `mkdir`, `git init`, `tickets init --code-prefix MYP` | "Resultant settings.yaml file in the `.tickets/` directory:" | `settings.yaml` |
| `cli_init_flags_example` | prompt, `--code-prefix`, custom `-d` variants | — | — |
| `cli_create_example` | `create` with short and full flags | "Resultant ticket file:" | created ticket file (postprocessed: long `TODO: ...` template instructions replaced with `TODO`) |
| `cli_validate_example` | single-ticket and `--tickets-dir` variants | — | — |
| `cli_list_example` | `list` default and flag variants (populates the `Example usage` TODO) | — | — |
| `cli_rank_example` | normalize and custom-dir variants | — | — |
| `cli_rank_mutations_example` | the four mutations (`up`/`down`/`first`/`last`) | — | — |
| `cli_transition_example` | transitions incl. targeting a done status | "Transitioned ticket file:" | transitioned ticket file |
| `cli_statistics_example` | `statistics snapshot` and reporting | "Metrics are printed to stdout as key-value pairs:" | stdout of `statistics snapshot` captured to a file |

# Execution Plan

## Phase 1 - Scripted harness in doc_update.sh and port of the help embeddings

At the conclusion of this phase `doc_update.sh` discovers embeddings from `test/examples/`, and every `cli_*` help snapshot in `Tickets System.md` is produced by a sourced example script under the renamed `cli_*_help` marker ids.

### Tasks

- [x] Extend `doc_update.sh` to discover embeddings from `test/examples/*.sh` (id = basename minus `.sh`), replacing the hardcoded identifier table; keep the `--file` override, unknown/unbalanced marker warnings, and non-zero exit when no embeddings are found or the target file is missing
- [x] Implement the sourcing harness: stage the script's `fixture()` fixture into a fresh execution directory under `test/executions/`, source the script, run its body with `$TICKETS_CLI` set, capture stdout as the transcript, and honor the optional `result_description()` and `result_file()` returns
- [x] Create the ten `cli_*_help.sh` scripts (`cli_list_help.sh`, `cli_init_help.sh`, `cli_create_help.sh`, `cli_validate_help.sh`, `cli_transition_help.sh`, `cli_statistics_help.sh`, `cli_rank_{up,down,first,last}_help.sh`) whose transcripts are the `--help` invocation and output
- [x] Rename the existing `cli_*` marker pairs in `Tickets System.md` to the new `cli_*_help` identifiers and regenerate; remove the now-unused shell-rendered help capture from `doc_update.sh`

### Verification Steps

- [x] Run `./doc_update.sh` twice in a row against the repository: the second run must produce no diff
- [x] Confirm every `cli_*_help` snapshot in `Tickets System.md` matches live `tickets <subcommand> --help` output, and the script reports no unknown scripts and no orphaned markers
- [x] Introduce a bogus `<!-- cli_bogus_help:start -->` marker in a scratch copy and confirm the script warns but still processes the known embeddings

## Phase 2 - Usage example scripts for all subcommands

Every hand-written example block in the CLI documentation sections is scripted, including the list `Example usage` TODO.

### Tasks

- [x] Create the `cli_*_example.sh` usage scripts (`cli_init_example.sh`, `cli_init_flags_example.sh`, `cli_create_example.sh`, `cli_validate_example.sh`, `cli_list_example.sh`, `cli_rank_example.sh`, `cli_rank_mutations_example.sh`, `cli_transition_example.sh`, `cli_statistics_example.sh`) per the contract, reusing or adding `test/fixtures/` fixtures as needed (new fixture `f004` with an initialized `.tickets/` under prefix `MYP`)
- [x] Add timestamp normalization to the captured transcripts so `create`/`transition` output is deterministic (ISO timestamps → fixed placeholder, execution-dir path stripped, git commit dates pinned)
- [x] Add `result_description()` returns matching the existing documentation style ("Resultant ticket file:", "Resultant settings.yaml file in the `.tickets/` directory:", "Metrics are printed to stdout as key-value pairs:") and `result_file()` returns where the docs show resultant files, including the stdout-capture pattern for `cli_statistics_example` (`tickets statistics snapshot > file` then return that file); scripts with no result omit `result_file()` entirely
- [x] Add `result_postprocess()` support to the harness (stdin → stdout transform applied to the result file before embedding) and apply it to `cli_create_example` so the created ticket's long `TODO: ...` template instructions render as simple `TODO`
- [x] Wrap every remaining example block in `Tickets System.md` with the matching marker pairs, populating the `Example usage` TODO block in the `list` section, and replace the `Example usage` heading as needed (redundant blocks removed: rank-walkthrough "Create some tickets" block, reference `create` flag variants, and the statistics "Snapshot Recording" section whose behavior is already covered by the section intro)
- [x] Run `./doc_update.sh` and confirm every covered block matches live CLI behavior, and that the result descriptions and result blocks render as in the existing documentation; audit for any remaining hand-maintained transcripts in the CLI documentation sections and wrap or remove them

### Verification Steps

- [x] Grep the CLI documentation sections: every example `bash` fence must sit between a matching marker pair, and the script must report no unknown scripts and no orphaned markers
- [x] Run `./doc_update.sh` twice in a row: no diff
- [x] Spot-check each scenario's transcript, description paragraph, and result-file block against a manual run of the same commands in a scratch project, including the `cli_statistics_example` stdout-capture result

## Phase 3 - Wire drift checking into the test suite and doc update path

Stale example transcripts fail CI, and the doc auto-update path keeps them fresh.

### Tasks

- [ ] Add a test case alongside the existing cases in `test/cases/` that runs `doc_update.sh` over a copy of the repository documentation and asserts zero diff, registered per the harness pattern in `test.sh`
- [ ] Confirm the doc auto-update path (`.github/workflows/doc-update.yaml`) continues to cover the regenerated `Tickets System.md` content (it already runs `./doc_update.sh`; adapt only if the file set changes)
- [ ] Document the mechanism in `Tickets System.md`: how to run it, the `test/examples/` directory convention, the script contract (`fixture()`, transcript body, `result_description()`, `result_file()`), the stdout-capture pattern, and the marker convention

### Verification Steps

- [ ] Run `./test.sh` and confirm the new case passes while all pre-existing cases still pass
- [ ] Temporarily stale one embedded transcript, re-run the new test case, and confirm it fails (then restore)
- [ ] Confirm the workflow definition runs `./doc_update.sh` as the drift step over all embedded content

# Follow-up

Not applicable.