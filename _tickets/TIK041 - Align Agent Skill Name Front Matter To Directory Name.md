---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK041
aliases:
  - TIK041
name: Align Agent Skill Name Front Matter To Directory Name
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-14T15:06:39Z
ticket_updated: 2026-06-14T15:28:19Z
ticket_completed: 2026-06-14T15:28:19Z
---
# Introduction

Update the `name` YAML front matter field in each SKILL.md under .apm/skills/ to match the parent directory name, replacing the current reversed naming convention with a consistent directory-derived name.

# Requirements

- `tickets-create/SKILL.md` name must change from `create-ticket` to `tickets-create`
- `tickets-execution-plan/SKILL.md` name must change from `execution-plan` to `tickets-execution-plan`
- `tickets-list/SKILL.md` name must change from `list-tickets` to `tickets-list`
- `tickets-rank/SKILL.md` name must change from `rank-ticket` to `tickets-rank`
- `tickets-review/SKILL.md` name must change from `review-ticket` to `tickets-review`
- `tickets-transition/SKILL.md` name must change from `transition-ticket` to `tickets-transition`
- Any references to the old name values in AGENTS.md or other configuration files must be updated to match

# Technical Solution

Edit the `name:` frontmatter field in each SKILL.md under `.apm/skills/` to match the parent directory name. The `.agents/skills/` directory is synchronized from `.apm/` by the APM command, so only the `.apm/skills/` source files need direct editing. After editing the source files, run the APM sync command to propagate changes to `.agents/skills/`. Finally, update the agent skills reference table in `Tickets.md` to use the new naming convention.

Files to edit:

| File                                                         | Old `name`          | New `name`              |
|--------------------------------------------------------------|---------------------|-------------------------|
| `.apm/skills/tickets-create/SKILL.md`                        | `create-ticket`     | `tickets-create`        |
| `.apm/skills/tickets-execution-plan/SKILL.md`                | `execution-plan`    | `tickets-execution-plan`|
| `.apm/skills/tickets-list/SKILL.md`                          | `list-tickets`      | `tickets-list`          |
| `.apm/skills/tickets-rank/SKILL.md`                          | `rank-ticket`       | `tickets-rank`          |
| `.apm/skills/tickets-review/SKILL.md`                        | `review-ticket`     | `tickets-review`        |
| `.apm/skills/tickets-transition/SKILL.md`                    | `transition-ticket` | `tickets-transition`    |

The `Tickets.md` table (lines 333-338) must be updated to reflect the new names.

# Execution Plan

- [ ] Update `name:` in `.apm/skills/tickets-create/SKILL.md` from `create-ticket` to `tickets-create`
- [ ] Update `name:` in `.apm/skills/tickets-execution-plan/SKILL.md` from `execution-plan` to `tickets-execution-plan`
- [ ] Update `name:` in `.apm/skills/tickets-list/SKILL.md` from `list-tickets` to `tickets-list`
- [ ] Update `name:` in `.apm/skills/tickets-rank/SKILL.md` from `rank-ticket` to `tickets-rank`
- [ ] Update `name:` in `.apm/skills/tickets-review/SKILL.md` from `review-ticket` to `tickets-review`
- [ ] Update `name:` in `.apm/skills/tickets-transition/SKILL.md` from `transition-ticket` to `tickets-transition`
- [ ] Run APM sync to propagate changes from `.apm/skills/` to `.agents/skills/`
- [ ] Update `Tickets.md` table to use new `tickets-<name>` convention for all six skills
- [ ] Grep for any remaining references to old `name` values outside of `_tickets/` historical files