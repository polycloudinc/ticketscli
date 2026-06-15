---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK043
aliases:
  - TIK043
name: Add Tickets Init Skill
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-15T13:35:22Z
ticket_updated: 2026-06-15T14:42:42Z
ticket_completed: 2026-06-15T14:42:41Z
---
# Introduction

Add a `tickets-init` agent skill that invokes the `tickets init` subcommand to bootstrap a new project with the tickets directory structure, settings, and template.

# Requirements

- Create `.apm/skills/tickets-init/SKILL.md` following the pattern of existing skills (e.g. `tickets-create`)
- The skill must include YAML frontmatter with `name: tickets-init` and a description matching the style of existing skill descriptions
- The skill description must specify when it should be activated: when the user asks to initialize a tickets system, bootstrap tickets, or set up the ticket directory structure
- Include the standard "About Tickets System" preamble used by all other skills, updating the subcommand list to include `init`
- Update `Tickets.md` with the `tickets-init` skill in the Agent Skills table, and update the subcommand list in the About Tickets System preamble across all existing skills to include `init`
- Document the `tickets init` subcommand usage: flags (`--code-prefix`, `-d`/`--tickets-dir`, `-h`/`--help`) and the interactive prompt behavior
- Sync the skill from `.apm/skills/` to `.agents/skills/`
- Add `tickets-init` to the Agent Skills table in `Tickets.md`

# Technical Solution

- Follow the exact structure of `.apm/skills/tickets-create/SKILL.md`: YAML frontmatter, About section, then procedural instructions
- The skill activates when the user asks to initialize, bootstrap, or set up the tickets directory structure
- Include the standard CLI invocation preamble (`bash tickets.sh` or `npx @aleisium/tickets`)
- Describe `init` behavior: creates `_tickets/` with `settings.yaml` and `statistics.yaml`, creates `_templates/Ticket.md`, supports `--code-prefix` flag or interactive prompt

# Execution Plan

- [x] Create `.apm/skills/tickets-init/SKILL.md` with YAML frontmatter (`name: tickets-init`, description), About Tickets System preamble (with `init` in subcommand list), and procedural instructions for running `tickets init`
- [x] Update the About Tickets System preamble in all existing skills to include `init` in the subcommand list
- [x] Copy the skill to `.agents/skills/tickets-init/SKILL.md`
- [x] Add `tickets-init` row to the Agent Skills table in `Tickets.md`
- [x] Verify the skill appears in the available skills listing and triggers correctly 