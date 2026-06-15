---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK044
aliases:
  - TIK044
name: Remove Template Copy From Init
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-15T14:59:12Z
ticket_updated: 2026-06-15T15:13:39Z
ticket_completed: 2026-06-15T15:13:38Z
---
# Introduction

The `init` subcommand currently copies the `Ticket.md` template file into the project's `_templates/` directory, and both `create` and `validate` read the template from that local copy or walk up the tree to find it. Additionally, the template lives in a separate module (`als-tickets-template`) with its own `package.json` publication. The template should be consolidated into the CLI module itself (`als-tickets-cli-main`), all commands should resolve it from the script's own directory, `init` should stop copying it, the separate template module should be removed, and the `_templates/` directory should no longer be created.

# Requirements

- `tickets init` must no longer create the `_templates/` directory or copy `Ticket.md` into it
- `tickets create` must locate the template file from the directory where `tickets.sh` resides (script directory), not by walking up the file tree looking for `_templates/Ticket.md`
- `tickets validate` must locate the template file from the script directory, same as `create`
- The `Ticket.md` template must be moved from `als-tickets-template/als-tickets-template-main/` into `als-tickets-cli/als-tickets-cli-main/` (it is already present there) and the `als-tickets-template` module must be removed entirely
- The `tickets.templateModule` reference in `package.json` must be removed since the template will be a direct file in the CLI module; the `files` array in `package.json` must include `Ticket.md` from its new location alongside `tickets.sh` in `als-tickets-cli/als-tickets-cli-main/` (it already does, but must be kept)
- Running `tickets init` on a project that already has `_templates/Ticket.md` from a previous version must not error on that stale file — `init` should ignore it
- Documentation in `Tickets.md` must be updated to reflect that the template source of truth is the file alongside `tickets.sh`

# Technical Solution

Consolidate the template into the CLI module. All commands (`create`, `validate`, `init`) resolve the template from `$(dirname "$(readlink -f "$0")")/Ticket.md` — the same directory where `tickets.sh` resides.

### Changes to `tickets.sh`

**`cmd_init`:** Remove the `mkdir -p "_templates"` block and the `cp` of `Ticket.md` into `_templates/`. The function should still create `_tickets/`, `settings.yaml`, and `statistics.yaml`, but no longer touch `_templates/` at all.

**`cmd_create`:** Replace the tree-walking logic that searches for `_templates/Ticket.md` with:
```bash
local script_dir
script_dir=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
local template_file="$script_dir/Ticket.md"
```

**`cmd_validate`:** Same replacement as `cmd_create`.

### Module consolidation

- Remove the `als-tickets-template/` directory entirely (component and module).
- Remove the `tickets.templateModule` field from `als-tickets-cli/als-tickets-cli-main/package.json`.
- Keep `Ticket.md` in `als-tickets-cli/als-tickets-cli-main/` and ensure it remains listed in `package.json`'s `files` array so `npm pack` includes it.

### `_templates/` directory on disk

Projects that ran a previous version of `init` will have a stale `_templates/Ticket.md`. This file is harmless — commands no longer reference it. If desired, it can be manually deleted or added to `.gitignore`. No automatic cleanup is performed.

### Documentation

Update `Tickets.md` section "Template Resolution" to state that the template is always resolved from the script directory alongside `tickets.sh`, removing references to `_templates/Ticket.md`, `package.json`'s `tickets.templateModule`, and the `als-tickets-template` module.

# Execution Plan

## Phase 1 — Update tickets.sh template resolution

- [ ] In `cmd_init`, remove the `mkdir -p "_templates"` block and the `cp` of `Ticket.md` into `_templates/`; keep `_tickets/`, `settings.yaml`, and `statistics.yaml` creation
- [ ] In `cmd_create`, replace the tree-walking logic for `_templates/Ticket.md` with `script_dir`-based resolution: `script_dir=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)` and `local template_file="$script_dir/Ticket.md"`
- [ ] In `cmd_validate`, apply the same `script_dir`-based template resolution as `cmd_create`
- [ ] Apply all three changes to `als-tickets-cli/als-tickets-cli-main/tickets.sh` as well (may be the same file if symlinked)

## Phase 2 — Remove template module

- [ ] Remove the `tickets.templateModule` field from `als-tickets-cli/als-tickets-cli-main/package.json`
- [ ] Delete the entire `als-tickets-template/` directory
- [ ] Verify `Ticket.md` is present in `als-tickets-cli/als-tickets-cli-main/` and listed in `package.json`'s `files` array

## Phase 3 — Update documentation

- [ ] Rewrite "Template Resolution" section in `Tickets.md` to describe script-directory-based resolution; remove references to `_templates/Ticket.md`, `package.json`'s `tickets.templateModule`, and the `als-tickets-template` module

## Phase 4 — Verification

- [ ] Run `tickets init` in a clean temp directory and confirm `_templates/` is not created
- [ ] Run `tickets create` and confirm it resolves the template from the script directory
- [ ] Run `tickets validate --all` and confirm all existing tickets pass
- [ ] Run `npm pack` from the CLI module directory and verify `Ticket.md` is included