---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK008
aliases:
  - TIK008
name: List Tickets Agent Skill
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 8
---

# Introduction

Create a narrowly scoped agent skill that teaches AI coding agents how to invoke the `tickets list` subcommand using natural-language keywords. This skill is separate from the existing `tickets` skill and must be strictly focused on listing tickets only. It must not explain ticket status lifecycles, ticket creation, ranking, kanban, execution plans, or any other aspect of the ticket system. Its sole purpose is mapping keywords to `tickets list` flags and showing the list output format.

# Requirements

- A new skill file must be created at `.agents/skills/list-tickets/SKILL.md`. This skill is independent from the existing `.agents/skills/tickets/SKILL.md`.
- The skill description must be narrow and explicit: it only applies when the user asks to `list tickets`, `show tickets`, or similar listing phrases. The user's request may also include a group keyword or status value to filter by.
- When the user provides a keyword or alias that maps to a group, the agent must use the `--group` switch:
  - `backlog` → `tickets list --group backlog`
  - `active` → `tickets list --group active`
  - `done` → `tickets list --group done`
- When the user provides a status value that is NOT a group keyword or alias (e.g., a specific status like `ready`, `in progress`, `duplicate`), the agent must use the `--status` switch instead:
  - `ready` → `tickets list --status ready`
  - `in progress` → `tickets list --status inprogress`
  - `duplicate` → `tickets list --status duplicate`
  - `won't fix` → `tickets list --status wontfix`
- The skill must handle common natural-language aliases for each **group** category so the agent infers the correct `--group` flag:
  - **backlog**: pending, unscheduled, queued, awaiting, todo, to-do, not started, upcoming
  - **active**: in progress, current, underway, being worked, working
  - **done**: completed, finished, closed, resolved, complete
- Note: The status field in ticket frontmatter is spelled `[[Backlog]]` (single 'g'), but the CLI group flag is `backlog` (double 'g'). Agents should use the CLI spelling (`backlog`) for `--group`.
- **Priority rule**: If a keyword matches both a group alias and a specific status, the `--status` filter takes priority because it is more specific (e.g., "in progress" maps to `--status inprogress`, not `--group active`).
- The `--status` switch must accept single-word, lowercase, space-free status values. Specifically, `"In Progress"` must be accepted as `inprogress` (case-insensitive, no spaces or underscores). The known status list in the CLI must be updated:
  - `backlog` (was already single-word)
  - `ready` (was already single-word)
  - `inprogress` (changed from `in progress`)
  - `complete` (was already single-word)
  - `duplicate` (was already single-word)
  - `wontfix` (changed from `won't fix` — remove apostrophe and space)
- The `--status` matching logic must strip spaces from the frontmatter status value before comparing, so that `inprogress` matches `[[In Progress]]` and `wontfix` matches `[[Won't Fix]]`.
- If no keyword or recognizable alias is given, the agent should run `tickets list` with no filter.
- The skill must include the alias table as a reference and provide concrete CLI examples for keyword + alias usage.
- The skill must NOT describe or reference: ticket status lifecycle, `tickets create`, `tickets rank`, `tickets kanban`, execution plan workflows, ticket file structure, or frontmatter format.
- The existing `.agents/skills/tickets/SKILL.md` and its parent directory must be deleted. This skill replaces it. Additionally, any stale copy at `.apm/skills/tickets/` must be removed if it exists.

# Technical Solution

Delete the existing `.agents/skills/tickets/SKILL.md` and its directory (and any stale copy at `.apm/skills/tickets/`), then create `.agents/skills/list-tickets/SKILL.md` following the standard skill format (frontmatter with `name: list-tickets` and a narrow `description` that limits its invocation scope to listing tickets only using trigger phrases like `list tickets` and `show tickets`, then markdown instructions). The content maps natural-language keywords to `tickets list --group` flags for group-level filtering and `tickets list --status` for specific status values, with `--status` taking priority when a keyword is ambiguous.

Before creating the skill, the `--status` switch in `tickets.sh` must be normalized to accept single-word, space-free status values:

- Replace `"in progress"` with `inprogress` and `"won't fix"` with `wontfix` in the `known` array.
- Update the error message to list the new single-word forms.
- In the filter application block, strip spaces from the frontmatter status before comparing against the resolved status, so `inprogress` matches `In Progress` and `wontfix` matches `Won't Fix`.
- Apply identical changes to `als-tickets-cli/als-tickets-cli-main/tickets.sh`.
- Update `Tickets.md` documentation accordingly.

After the CLI change, the skill's examples must use the new single-word status forms (e.g., `tickets list --status inprogress`).

# Execution Plan

- [x] 1. In `tickets.sh` (line 73): replace `"in progress"` with `inprogress` and `"won't fix"` with `wontfix` in the `known` array for `--status`.
- [x] 2. In `tickets.sh` (line 89): update the error message to list single-word statuses: `inprogress`, `wontfix`.
- [x] 3. In `tickets.sh` (lines 131-136): in the `status:*` filter case, strip spaces from `$status` before lowercasing and comparing (`tr -d ' '`), so `In Progress` matches `inprogress` and `Won't Fix` matches `wontfix`.
- [x] 4. In `Tickets.md` (line 50): update the `--status` row to document single-word forms (`backlog`, `ready`, `inprogress`, `complete`, `duplicate`, `wontfix`) and note they are case-insensitive.
- [x] 5. Delete `.agents/skills/tickets/SKILL.md` and its parent directory.
- [x] 6. Delete `.apm/skills/tickets/SKILL.md` and its parent directory if it exists.
- [x] 7. Create `.agents/skills/list-tickets/` directory.
- [x] 8. Create `.agents/skills/list-tickets/SKILL.md` with frontmatter `name: list-tickets` and a narrow `description` that restricts invocation scope to listing tickets (trigger phrases: `list tickets`, `show tickets`, and similar).
- [x] 9. Include in SKILL.md:
  - **Group mapping table**: `backlog` → `--group backlog`, `active` → `--group active`, `done` → `--group done`.
  - **Alias table**: backlog (pending, unscheduled, queued, awaiting, todo, to-do, not started, upcoming); active (in progress, current, underway, being worked, working); done (completed, finished, closed, resolved, complete). Exclude `open` from active aliases.
  - **Status mapping**: `ready` → `--status ready`, `in progress` → `--status inprogress`, `duplicate` → `--status duplicate`, `won't fix` → `--status wontfix`.
  - **Priority rule**: when a keyword matches both a group alias and a status, `--status` wins because it is more specific.
  - **Backlog spelling note**: frontmatter uses `[[Backlog]]` (single 'g'), CLI group flag is `backlog` (double 'g').
  - **No filter default**: if no keyword or alias, run `tickets list` with no filter.
  - Do NOT include: ticket lifecycle, create, rank, kanban, execution plans, ticket file structure, or frontmatter format.
- [x] 10. Verify `tickets list --group active` lists Ready and In Progress tickets.
- [x] 11. Verify `tickets list --group backlog` lists only Backlog tickets.
- [x] 12. Verify `tickets list --group done` lists Complete, Duplicate, and Won't Fix tickets.
- [x] 13. Verify `tickets list --status inprogress` lists only In Progress tickets.
- [x] 14. Verify `tickets list --status wontfix` lists only Won't Fix tickets.
- [x] 15. Verify no old `--active`, `--backlog`, or `--done` flags exist in any skill or documentation.
