---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK018
aliases:
  - TIK018
name: Create Ticket Agent Skill
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
---

# Introduction

Create an agent skill that instructs agents to create new tickets using the `tickets create` subcommand, deriving the ticket name from the user's request.

# Requirements

- A new skill file must be created at `.apm/skills/create-ticket/SKILL.md` (canonical) with a symlink from `.agents/skills/create-ticket/SKILL.md`, following the same pattern as the existing `review-ticket`, `list-tickets`, and `execution-plan` skills.
- The skill must only apply when the user asks to create a new ticket.
- The skill must instruct the agent to use `tickets create -n <subject>` (or `--name <subject>`) to create the ticket file.
- The agent must derive an appropriate, concise name for the ticket from the user's message and pass it to the `-n` switch.
- After creation, the agent must review the newly created ticket using the `review-ticket` skill.
- The skill must include the standard About section describing the tickets system (same content as other skills, sourced from `SKILL-ABOUT.md` and synced automatically by `update-about.sh` for any skill under `.apm/`).

# Technical Solution

Create `.apm/skills/create-ticket/SKILL.md` with frontmatter fields `name: create-ticket` and a narrow `description`. The prompt instructs the agent to extract a ticket name from the user's request, invoke `tickets create -n <name>`, and then load and execute the `review-ticket` skill against the newly created ticket. Create a symlink at `.agents/skills/create-ticket/SKILL.md` pointing to the canonical source at `.apm/skills/create-ticket/SKILL.md`. The About section is synced from `SKILL-ABOUT.md` via `update-about.sh`, which automatically covers any skill created under `.apm/skills/`.

# Execution Plan

### Implementation

- [x] Create directory `.apm/skills/create-ticket/`.
- [x] Write `SKILL.md` with YAML frontmatter (`name: create-ticket`, narrow `description` restricting invocation to when the user asks to create a ticket).
- [x] Add the standard About section (synced automatically by `update-about.sh`).
- [x] Write the prompt body instructing the agent to: extract a concise ticket name from the user's message, invoke `tickets create -n <name>`, and then use the `review-ticket` skill on the new ticket.
- [x] Create symlink at `.agents/skills/create-ticket/SKILL.md` → `.apm/skills/create-ticket/SKILL.md`.

### Verification

- [x] Verify the skill appears in the agent skills list and is loadable.
- [x] Verify the skill correctly triggers `tickets create -n <name>` and creates a valid ticket file.
- [x] Verify the skill invokes `review-ticket` on the newly created ticket.
- [x] Verify `tickets create --help` output is consistent with the skill's instructions.
