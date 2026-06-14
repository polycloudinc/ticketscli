---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK006
aliases:
  - TIK006
name: Create Subcommand
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-09T06:11:51Z
---
# Introduction

Add a `create` subcommand to the `tickets` CLI that creates a new ticket file from the template, auto-assigning the next ticket code.

# Requirements

- `tickets create --name <subject>` (short form `-n`) creates a new `.md` ticket file in the `_tickets/` directory. Supports `-d, --tickets-dir <path>` to specify an alternate tickets directory (defaults to `_tickets`).
- The ticket code prefix is read from `_tickets/settings.yaml` under the key `code_prefix`. For example, `code_prefix: TIK` produces codes `TIK001`, `TIK002`, etc. If the file or key is missing, the command exits with an error.
- The next ticket number is determined by scanning existing ticket files in the tickets directory, extracting the numeric portion from the code prefix, and taking `max + 1`. If no tickets exist, numbering starts at 1.
- The new file is named `<Prefix><NNN> - <Subject>.md` where `<NNN>` is zero-padded to 3 digits (e.g. `TIK006`).
- The template is read from the `_templates/Ticket.md` file located via repo-root discovery (same approach used by `cmd_validate`).
- The new file is written with the frontmatter populated: `code`, `aliases`, `name`, `ticket_status` set to `[[Backlog]]`, and `ticket_priority` set to `Medium`.
- If a ticket with the same code already exists (unlikely but possible), the command exits with an error.

# Technical Solution

In `tickets.sh`, add a `cmd_create` function that reads `_tickets/settings.yaml` to get the `code_prefix`. Scan existing ticket filenames in the tickets directory to find the highest numeric suffix. Locate the template at `_templates/Ticket.md` via repo-root discovery (same as `cmd_validate`). Populate the frontmatter fields from the provided `--name` value and computed code, and write the new file to the tickets directory. Wire into the top-level subcommand dispatch.

# Execution Plan

### Implementation

- [x] Implement `cmd_create_usage()` help text listing `--name` / `-n`, `--tickets-dir` / `-d`, and `--help` / `-h`.
- [x] Implement `cmd_create()` argument parsing: require `--name` / `-n`, support optional `--tickets-dir` / `-d` (default `_tickets`), handle `-h`/`--help`, reject unknown flags.
- [x] Implement repo-root discovery (walk up from CWD to find `_templates/Ticket.md`, same approach as `cmd_validate`).
- [x] Read `code_prefix` from `<tickets-dir>/settings.yaml`; exit with error if file or key is missing.
- [x] Scan ticket filenames in the tickets directory, extract numeric portion after the prefix, compute `max + 1` (zero-padded to 3 digits). If no tickets exist, start at 001.
- [x] Check that no existing ticket already has the computed code; exit with error if a collision is detected.
- [x] Read the template from `_templates/Ticket.md`, populate the frontmatter with `code`, `aliases` (single entry matching `code`), `name` (from `--name`), `ticket_status: "[[Backlog]]"`, `ticket_priority: Medium`, and the body sections from the template.
- [x] Write the new file to the tickets directory named `<Prefix><NNN> - <Subject>.md`.
- [x] Wire `cmd_create` into the top-level subcommand dispatch and update `usage()`.
- [x] Propagate changes to the root `tickets.sh` if different from the CLI source.

### Verification

- [x] `tickets create --name "Test Feature"` creates a file with the correct code, name, and frontmatter fields.
- [x] Created ticket has `ticket_status: "[[Backlog]]"` and `ticket_priority: Medium`.
- [x] `tickets create -n "Short Form"` works with the short option.
- [x] `tickets create -d /tmp/testdir --name "Test"` uses the specified tickets directory.
- [x] Error when `_tickets/settings.yaml` is missing or lacks `code_prefix`.
- [x] Numbering starts at 001 when no tickets exist in an empty directory.
- [x] Error when a ticket with the generated code already exists.
- [x] `tickets create --help` shows usage text.
- [x] `tickets create` without `--name` exits with an error.
