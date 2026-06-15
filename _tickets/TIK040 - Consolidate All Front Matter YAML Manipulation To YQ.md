---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK040
aliases:
  - TIK040
name: Consolidate All Front Matter YAML Manipulation To YQ
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-14T15:04:35Z
ticket_updated: 2026-06-15T05:24:25Z
ticket_completed: 2026-06-15T05:24:24Z
---
# Introduction

Standardize all front matter YAML reading and manipulation in tickets.sh to use mikefarah/yq instead of ad-hoc sed/grep pipelines, ensuring consistent and robust YAML handling across all subcommands.

# Requirements

- All front matter field reads must use `yq eval --front-matter extract` instead of `sed -n '/^---$/,/^---$/p' | grep | sed` pipelines
- All front matter field writes must use `yq eval -i` instead of `sed -i` in-place edits
- `get_ticket_rank` helper must use yq
- `set_ticket_rank` helper must use yq
- `normalize_ranks` must use yq for reading status and rank
- `cmd_list` must use yq for reading name, status, and rank fields
- `cmd_create` must use yq for reading existing ranks
- `cmd_transition` must use yq for reading and writing ticket_status, ticket_rank, ticket_completed, and ticket_updated
- `touch_ticket_updated` must use yq for deleting and inserting ticket_updated
- `settings.yaml` reads must use yq consistently (`cmd_create` currently uses sed, `cmd_validate` uses yq)

# Technical Solution

Replace all `sed -n '/^---$/,/^---$/p' | grep | sed` front matter reads with `yq eval --front-matter extract` and all `sed -i` front matter writes with `yq eval -i --front-matter process`. yq (mikefarah/yq Go) is already required and verified in `cmd_validate`; extend that dependency to all subcommands. Creating new front matter from scratch (e.g. `cmd_create`'s `printf` block) does not need yq — only reading/writing existing YAML.

Key yq patterns:
- Read field: `yq eval --front-matter extract '.field // ""' file.md`
- Write field: `yq eval -i --front-matter process '.field = "value"' file.md`
- Clear field (keep key): `yq eval -i --front-matter process '.field = ""' file.md`
- Delete field: `yq eval -i --front-matter process 'del(.field)' file.md` (removes key entirely)
- Chained writes: `yq eval -i --front-matter process '.a = "x" | .b = "y"' file.md`

Critical: `--front-matter extract` with `-i` strips the body content. Always use `--front-matter process` for in-place writes to preserve the Markdown body.
- `cmd_create` (line 782): reads `code_prefix` from `settings.yaml` via sed while `cmd_validate` (line 935) uses yq — align to yq.

# Execution Plan

- [x] **1. `get_ticket_rank` helper** — Replace with `yq eval --front-matter extract`. (tickets.sh:201)
- [x] **2. `set_ticket_rank` helper** — Replace `sed -i` with `yq eval -i --front-matter process`. (tickets.sh:209)
- [x] **3. `touch_ticket_updated` helper** — Replace dual `sed -i` with `yq eval -i --front-matter process`. (tickets.sh:218-221)
- [x] **4. `normalize_ranks`** — Replace sed reads/writes with yq. Use `.ticket_rank = ""` (not `del()`) to preserve key for validation. (lines 150, 156, 165, 178)
- [x] **5. `cmd_list`** — Replace sed front matter extraction with yq reads. (lines 660-663, 680)
- [x] **6. `cmd_create`** — Replace sed settings.yaml read and rank read with yq. (lines 782, 809)
- [x] **7. `cmd_transition`** — Replace sed reads/writes with yq. (lines 1224, 1243-1276)
- [x] **8. `cmd_rank_up` / `cmd_rank_down` / `cmd_rank_first` / `cmd_rank_last`** — Verified working after helper migration.
- [x] **9. `cmd_statistics_snapshot`** — Already uses yq. No changes needed.
- [x] **10. Smoke test** — All subcommands pass, validate --all returns no deviations, body content preserved.