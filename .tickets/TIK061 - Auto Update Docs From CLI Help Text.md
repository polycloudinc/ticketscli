---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK061
aliases:
- TIK061
name: Auto Update Docs From CLI Help Text
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank: null
ticket_created: '2026-08-16T03:38:31Z'
ticket_updated: '2026-08-16T04:59:34Z'
ticket_completed: '2026-08-16T04:59:28Z'
---
# Introduction

Documentation such as `Tickets System.md` describes the CLI subcommands by hand, so it drifts out of sync with the actual help text as flags and defaults change. Provide a mechanism that generates the CLI reference documentation directly from each subcommand's `--help` output, keeping the docs accurate without manual transcription.

# Requirements

- The mechanism must support a predefined set of embedding identifiers, each mapping to a subcommand (or subcommand variant) whose `--help` output it can embed; the initial set is `cli_list` (the `list` subcommand), to be extended to cover all subcommands and `rank` variants over time
- Each embedding is demarcated in the documentation by a pair of HTML comments `<!-- <id>:start -->` and `<!-- <id>:end -->`; the mechanism replaces only the content between the markers with the freshly captured command output (kept in a code-fenced block), leaving hand-written surrounding text untouched
- The mechanism must process every known embedding found in the target documentation file(s); unknown or unmatched markers must be reported (warned about) so typos do not silently pass
- The mechanism must build each embeddable output by invoking the live CLI (e.g. `tickets list --help` for `cli_list`), so the embedded snapshots always match the real CLI
- Re-running the mechanism must be idempotent: running it twice produces no diff
- The mechanism must be discoverable and documented — e.g. documented in `Tickets System.md` and/or wired into the test suite so drift between help text and docs fails CI
- Formatting must be normalized appropriately (e.g. help captured in a code fence) so the output renders correctly in Markdown
- This depends on the help text being accurate (see TIK060), so the mechanism may be implemented in parallel but must be verified against the polished help output
- No hand-maintained CLI reference text may remain in the documentation once the mechanism exists
- A GitHub Actions workflow must run the doc update automatically and open a pull request with any resulting changes, so CLI help changes ripple into the documentation without manual runs

# Technical Solution

The doc update process is scripted in a bash script `doc_update.sh` at the repository root.

The GitHub Actions workflow that runs it should be a **new dedicated workflow** (`.github/workflows/doc-update.yaml`) rather than folding into the existing `test.yaml` or `publish-npm.yaml`:

- `test.yaml` is a read-only verification job (no `contents: write`); auto-committing from it would blur its purpose and require permission changes.
- `publish-npm.yaml` is scoped to package publication with its own triggers and secret needs.

Design decisions:

- **PR flow**: when `./doc_update.sh` produces a diff, the workflow creates a branch, commits the doc change, pushes it, and opens a pull request against `master`. No direct pushes to `master`.
- **Bot identity**: the auto-commit uses a bot identity (e.g. `github-actions[bot]`, email `41898282+github-actions[bot]@users.noreply.github.com`) so the change is not attributed to a human author.
- **Loop safety**: branches pushed by `GITHUB_TOKEN` do not trigger workflow runs, and `Tickets System.md` stays out of the push `paths` filter; the PR must be merged manually, and a merged doc-only commit produces no diff on the next run, so no new PR is opened.
- **Concurrency**: a `concurrency` group serializes runs so overlapping executions cannot race on branch/PR creation.
- **File extension consolidation**: all workflow files are renamed to the `.yaml` extension (`test.yaml` → `test.yaml`), so the workflows directory is consistent.
- **Triggers**: push to `master` on CLI-impacting paths, `pull_request`, and `workflow_dispatch`.

TODO

# Execution Plan

## Phase 1 - Implement doc_update.sh with cli_list support

At the conclusion of this phase the script replaces the content of the existing `cli_list` marker block in `Tickets System.md` with the live `tickets list --help` output, idempotently.

### Tasks

- [x] Create `doc_update.sh` at the repository root: a bash script that scans a target Markdown file (default `Tickets System.md`) for `<!-- <id>:start -->` / `<!-- <id>:end -->` marker pairs
- [x] Define the embedding identifier table in the script, initially mapping `cli_list` to the `list` subcommand; the script resolves the CLI relative to its own directory (`$SCRIPT_DIR/tickets.sh <subcommand> --help`)
- [x] For each known identifier found, replace everything between the markers with a code-fenced snapshot: the invocation line (`tickets <subcommand> --help`) followed by the captured help output, preserving the marker comments
- [x] Warn on stderr for `:start` markers with an unknown identifier and for unbalanced marker pairs (a `:start` without a matching `:end`, or vice versa) without aborting
- [x] Exit non-zero if no markers were found or if the target file does not exist

### Verification Steps

- [x] Run `./doc_update.sh` twice in a row against the repository: the second run must produce no diff (`git diff` clean after the first run)
- [x] Copy `Tickets System.md` to a scratch file, manually stale the content between the `cli_list` markers, run the script on the copy with a `--file` override, and confirm the block now matches the live `tickets list --help` output while surrounding prose is untouched
- [x] Introduce a bogus `<!-- cli_bogus:start -->` marker in the scratch file and confirm the script warns about the unknown identifier but still processes `cli_list`

## Phase 2 - Wire doc update into the test suite

The drift between the CLI help text and the documentation becomes a regression test so stale snapshots fail CI.

### Tasks

- [x] Add a test case (e.g. `tc011_doc_update.sh` alongside the existing cases in `test/cases/`) that runs `doc_update.sh` over a copy of the repository documentation and asserts zero diff
- [x] Register the test case in `test.sh`'s case list or discovery mechanism per the existing harness pattern
- [x] Document the `doc_update.sh` usage in `Tickets System.md` (how to run it, what it updates, and the marker convention)

### Verification Steps

- [x] Run `./test.sh` and confirm the new doc-update case passes while all pre-existing cases still pass
- [x] Temporarily stale the `cli_list` block in the committed doc, re-run the new test case, and confirm it fails (then restore the doc)

## Phase 3 - Extend embeddings to all subcommands

The mechanism covers every subcommand so no hand-maintained CLI reference text remains.

### Tasks

- [x] Register embedding identifiers for all remaining subcommands (`init`, `create`, `validate`, `transition`, `statistics`) and the `rank` variants (`up`, `down`, `first`, `last`) in `doc_update.sh`
- [x] Add `<!-- cli_<id>:start -->` / `<!-- cli_<id>:end -->` marker pairs around every help snapshot in `Tickets System.md`, including the unmarked `rank up` snapshot in the `rank` section
- [x] Run `./doc_update.sh` to regenerate all blocks and confirm the documentation matches the live CLI
- [x] Audit `Tickets System.md` for any remaining unmarked, hand-maintained help text and either wrap it in markers or remove it

### Verification Steps

- [x] Grep `Tickets System.md` for help snapshots: every one must sit between a matching marker pair, and `./doc_update.sh` must report no unknown or unbalanced markers
- [x] Confirm all generated snapshots match the live output of `tickets <subcommand> --help` for every registered identifier
- [ ] Once TIK060 lands (polished help text), rerun `./doc_update.sh` and the test suite and confirm the doc snapshots reflect the polished output

## Phase 4 - GitHub Actions workflow for doc auto-update

The documentation stays in sync automatically: when CLI changes affect help output, the workflow regenerates snapshots, commits the result on a branch as a bot, and opens a pull request.

### Tasks

- [x] Rename `.github/workflows/test.yaml` to `.github/workflows/test.yaml` (extension consolidation) and update any references to the old name — no rename required: all three workflows already use the `.yaml` extension
- [x] Add `.github/workflows/doc-update.yaml` with a `concurrency` group (cancel-in-progress) and `permissions: contents: write`; triggers: push to `master` with `paths` covering `polycloud-tickets-cli/**`, `.github/workflows/doc-update.yaml`, and `test/cases/**` (never `Tickets System.md`), plus `pull_request` and `workflow_dispatch`
- [x] Steps: checkout (fetch-depth 0) → install python3 pyyaml → run `./doc_update.sh` → if `git diff --quiet -- "Tickets System.md"` fails (changes present), create a branch, stage and commit with the bot identity (`github-actions[bot]` / `41898282+github-actions[bot]@users.noreply.github.com`) and message `Docs: refresh CLI help snapshots`, push the branch, and open a PR against `master` via `gh pr create`
- [x] On `pull_request` runs, only check for drift (report status) without creating branches/PRs, so PRs validate the snapshots without recursion
- [x] Keep the existing `tc011_doc_update.sh` drift check in `test.yaml` as the read-only guard; the new workflow is the write path

### Verification Steps

- [ ] Manually stale a snapshot in `Tickets System.md` and trigger the workflow (`workflow_dispatch` on a test branch): confirm a PR is opened whose only change is the restored snapshot, authored by the bot identity
- [ ] Merge the generated PR and re-trigger the workflow: confirm no new branch or PR is produced (doc already in sync)
- [ ] Confirm `pull_request` runs report drift status but never push branches or open PRs
- [ ] Confirm `test.yaml` continues to pass on the workflow-generated commit (drift check green)