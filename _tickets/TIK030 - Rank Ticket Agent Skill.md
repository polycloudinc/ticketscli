---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK030
aliases:
  - TIK030
name: Rank Ticket Agent Skill
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-14T07:20:15Z
ticket_updated: 2026-06-14T08:13:51Z
ticket_completed: 2026-06-14T08:13:51Z
---
# Introduction

Create a new `rank-ticket` agent skill that exposes the CLI `rank up`, `rank down`, `rank first`, and `rank last` subcommands to AI agents, allowing users to promote, demote, or reposition tickets in the priority stack via natural language.

# Requirements

- A new `rank-ticket` skill file is created at `.apm/skills/rank-ticket/SKILL.md`.
- The skill handles natural-language phrases such as "promote TIK005", "demote TIK003", "move TIK007 to the top", "send TIK012 to the bottom", "bump TIK004 up", and similar ranking requests.
- The skill maps user phrasing to the correct CLI subcommand: `rank up`, `rank down`, `rank first`, or `rank last`.
- The skill extracts the ticket code from the user's message and invokes `bash tickets.sh rank <subcommand> -t <code>`.
- The skill reports the result (new rank position or "already at highest/lowest priority") back to the user.
- The skill's About section is consistent with the canonical `SKILL-ABOUT.md` (already updated to include `rank` among the subcommands) and each section matches that canonical source.
- The skill is listed in the agent skills table in `Tickets.md`. The canonical source for available skills is the `.apm/skills/` directory tree.
- The skill follows the same structure conventions as existing skills (frontmatter with name/description, About section, and instructional body).

# Technical Solution

The skill follows the pattern established by `transition-ticket`: a frontmatter block with `name` and `description`, the About section (injected from the canonical `SKILL-ABOUT.md` via `update-about.sh`), and an instructional body that breaks down the workflow into numbered steps.

**Natural language to subcommand mapping:**

| User phrasing                                          | Subcommand   |
|--------------------------------------------------------|--------------|
| promote, bump up, move up, rank up                     | `rank up`    |
| demote, bump down, move down, rank down, push down     | `rank down`  |
| move to the top, send to the top, rank first, top      | `rank first` |
| move to the bottom, send to bottom, rank last, bottom  | `rank last`  |

**Ticket code extraction**: The skill extracts a ticket code matching the pattern `<code_prefix>\d{3}` (e.g., `TIK005`) from the user's message. The code prefix is read from `_tickets/settings.yaml` at runtime; if no prefix is configured, the skill defaults to extracting any `[A-Z]{2,4}\d{3}` pattern.

**CLI invocation**: `bash tickets.sh rank <subcommand> -t <code>`. The CLI handles normalization and boundary messages internally; the skill reports output verbatim to the user.

# Execution Plan

### Phase 1: Create Skill File

- [x] Create directory `.apm/skills/rank-ticket/`.
- [x] Write `.apm/skills/rank-ticket/SKILL.md` with frontmatter (`name: rank-ticket`, description matching the invocation-rule pattern used by other skills: "Use when the user asks to... Do not use for...").
- [x] Include the canonical About section (identical to what `update-about.sh` would produce).
- [x] Write instructional body covering: (1) map user phrasing to `rank` subcommand, (2) extract ticket code, (3) invoke CLI, (4) report result.

### Phase 2: Register and Verify

- [x] Run `update-about.sh` to ensure the About section is in sync with the canonical source.
- [x] Verify the skill file is present in `.apm/skills/rank-ticket/SKILL.md`.
- [x] Confirm `rank-ticket` is listed in the `Tickets.md` agent skills table (already added during prerequisite cleanup).
- [x] Test end-to-end: use the skill to promote, demote, move-to-top, and move-to-bottom a test ticket, confirming the CLI responds correctly.
- [x] Verify boundary behavior: promoting a rank-1 ticket or demoting the lowest-ranked ticket produces the expected "already at boundary" message. 