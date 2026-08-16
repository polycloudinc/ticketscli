---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK061
aliases:
  - TIK061
name: Auto Update Docs From CLI Help Text
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 18
ticket_created: 2026-08-16T03:38:31Z
ticket_updated: 2026-08-16T03:38:31Z
ticket_completed:
---
# Introduction

Documentation such as `Tickets System.md` describes the CLI subcommands by hand, so it drifts out of sync with the actual help text as flags and defaults change. Provide a mechanism that generates the CLI reference documentation directly from each subcommand's `--help` output, keeping the docs accurate without manual transcription.

# Requirements

- A mechanism (script/command) must collect the help output of every subcommand — including `rank` variants (up/down/first/last) and the top-level usage — by invoking the live CLI, and write it into the documentation in a well-defined location
- The generated documentation section must be clearly marked (e.g. fenced markers or a dedicated file) so regeneration fully replaces stale content without touching hand-written surrounding text
- Re-running the mechanism must be idempotent: running it twice produces no diff
- The mechanism must be discoverable and documented — e.g. documented in `Tickets System.md` and/or wired into the test suite so drift between help text and docs fails CI
- Performance and formatting requirements: the generated content must preserve the CLI's terminal formatting appropriately (or specify how it is normalized) for Markdown display
- This depends on the help text being accurate (see TIK060), so the mechanism may be implemented in parallel but must be verified against the polished help output
- No hand-maintained CLI reference text may remain in the documentation once the mechanism exists

# Technical Solution

TODO

# Execution Plan

TODO 