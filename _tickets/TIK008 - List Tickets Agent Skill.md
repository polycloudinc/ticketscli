---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK008
aliases:
  - TIK008
name: List Tickets Agent Skill
subjects: cli
ticket_status: "[[Backlog]]"
ticket_priority: Medium
---

# Introduction

Create a narrowly scoped agent skill that teaches AI coding agents how to invoke the `tickets list` subcommand using natural-language keywords. This skill is separate from the existing `tickets` skill and must be strictly focused on listing tickets only. It must not explain ticket status lifecycles, ticket creation, ranking, kanban, execution plans, or any other aspect of the ticket system. Its sole purpose is mapping keywords to `tickets list` flags and showing the list output format.

# Requirements

- A new skill file must be created at `.agents/skills/list-tickets/SKILL.md`. This skill is independent from the existing `.agents/skills/tickets/SKILL.md`.
- The skill description must be narrow and explicit: it only applies when the user asks to list tickets, and it only covers the `list` subcommand.
- The skill instructs agents that when a user asks to list tickets using keywords, the agent should map them as follows:
  - `backlog` → `tickets list --backlog`
  - `active` → `tickets list --active`
  - `done` → `tickets list --done`
- The skill must handle common natural-language aliases for each category so the agent infers the correct flag without explicit keywords:
  - **backlog**: pending, unscheduled, queued, awaiting, todo, to-do, not started, upcoming
  - **active**: in progress, current, underway, being worked, open, working
  - **done**: completed, finished, closed, resolved, complete
- If no keyword or recognizable alias is given, the agent should run `tickets list` with no filter.
- The skill must include the alias table as a reference and provide concrete CLI examples for keyword + alias usage.
- The skill must NOT describe or reference: ticket status lifecycle, `tickets create`, `tickets rank`, `tickets kanban`, execution plan workflows, ticket file structure, or frontmatter format.

# Technical Solution

Create `.agents/skills/list-tickets/SKILL.md` following the standard skill format (frontmatter with `name: list-tickets` and a narrow `description` that limits its invocation scope to listing tickets only, then markdown instructions). The content maps the three natural-language keywords to the corresponding `tickets list` flags and provides a simple lookup table the agent can reference.

# Execution Plan

- [ ] Create the `.agents/skills/list-tickets/` directory.
- [ ] Draft the `SKILL.md` content with keyword-to-flag mapping, an alias table covering backlog/active/done synonyms, and CLI examples. Keep it narrow — no lifecycle, no create/rank/kanban.
- [ ] Verify the skill description and instructions do not reference anything outside of listing tickets.
- [ ] Verify the skill is loadable by the agent skill system.
- [ ] Verify `tickets list` shows TIK008 after creating it.
