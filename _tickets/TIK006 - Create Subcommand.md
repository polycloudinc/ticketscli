---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK006
aliases:
  - TIK006
name: Create Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
---
# Introduction

Add a `create` subcommand to the `tickets` CLI that creates a new ticket file from the template, auto-assigning the next ticket code and rank.

# Requirements

- `tickets create --name <subject>` (short form `-n`) creates a new `.md` ticket file in the `_tickets/` directory.
- The ticket code prefix is read from `_tickets/settings.yaml` under the key `ticket_prefix`. For example, `ticket_prefix: TIK` produces codes `TIK001`, `TIK002`, etc. If the file or key is missing, the command exits with an error.
- The next ticket number is determined by scanning existing ticket files in `_tickets/`, extracting the numeric portion from the code prefix, and taking `max + 1`. If no tickets exist, numbering starts at 1.
- The ticket's `ticket_rank` is set to the next available rank (one more than the current highest rank), effectively adding the ticket to the bottom of the priority list.
- The new file is named `<Prefix><NNN> - <Subject>.md` where `<NNN>` is zero-padded to 3 digits (e.g. `TIK006`).
- The template is read from the `_tickets/` directory (not a hardcoded path) — specifically from the file referenced by `settings.yaml` under the key `template` (defaulting to `Ticket.md` in the template if absent).
- The new file is written with the frontmatter populated: `code`, `aliases`, `name`, `ticket_status` set to `[[Backlog]]`, `ticket_priority` set to `Medium`, and `ticket_rank` set to the computed value.
- If a ticket with the same code already exists (unlikely but possible), the command exits with an error.

# Technical Solution

Create a `_tickets/settings.yaml` file with `ticket_prefix` and optionally `template`. In `tickets.sh`, add a `cmd_create` function that reads `settings.yaml` to get the prefix and template path. Scan existing ticket filenames to find the highest numeric suffix. Read the template file, populate the frontmatter fields from the provided `--name` value and computed code/rank, and write the new file to `_tickets/`. Wire into the top-level subcommand dispatch.

# Execution Plan

- [ ] Create `_tickets/settings.yaml` with `ticket_prefix` and `template` keys.
- [ ] Implement `cmd_create` that reads settings, determines next code and rank, and writes the new ticket file.
- [ ] Wire `cmd_create` into the top-level subcommand dispatch and usage output.
- [ ] Verify `tickets create --name "Test Feature"` creates a file with the correct code, rank, and frontmatter.
- [ ] Verify the created ticket has `ticket_status: "[[Backlog]]"` and `ticket_priority: Medium`.
- [ ] Verify the created ticket rank is one higher than the previously highest rank.
- [ ] Verify `tickets create -n "Short Form"` works with the short option.
- [ ] Verify error when `_tickets/settings.yaml` is missing or lacks `ticket_prefix`.
- [ ] Verify numbering starts at 001 when no tickets exist (test with an empty `_tickets/` directory).
