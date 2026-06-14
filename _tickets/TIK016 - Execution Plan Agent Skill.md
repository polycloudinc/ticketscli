---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK016
aliases:
  - TIK016
name: Execution Plan Agent Skill
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-13T08:13:50Z
---

# Introduction

Create a simple agent skill that instructs agents to build an execution plan as a checkbox list of tasks for each ticket. The skill must be created under `.apm/skills/execution-plan/` so it is packaged and published via APM (`includes: auto`).

# Requirements

- A new agent skill file must be created at `.apm/skills/execution-plan/SKILL.md`.
- The skill must have frontmatter with `name: execution-plan` and a `description` that explains when the skill should be invoked — specifically when the user asks to create, update, or check off execution plan items in a ticket.
- The skill content must be simple and focused: instruct the agent to build a linear checkbox list (`- [ ]` / `- [x]`) of tasks under an `# Execution Plan` heading.
- The tasks must be broken into separate phases (each a level-three heading with a phase name) when:
  - The total number of tasks exceeds 5, or
  - Tasks touch logically different parts of the system but can be completed and tested individually — each distinct component becomes its own phase.
- APM installs the skill locally into `.agents/skills/` — no symlink or manual linking is needed.

# Technical Solution

Create `.apm/skills/execution-plan/SKILL.md` with frontmatter and a short prompt. The root `apm.yml` uses `includes: auto`, so the new skill directory will be auto-discovered without any manifest changes. The skill content instructs agents on the checkbox format and the two conditions that trigger breaking tasks into named phases.

# Execution Plan

### Setup

- [x] Create `.apm/skills/execution-plan/` directory.

### Implementation

- [x] Draft the `SKILL.md` content with the simple execution plan format guidance and phase-splitting rules.
- [x] Run `update-about.sh` to apply the canonical About section to the new skill.
- [x] Run `apm install` to deploy the skill into `.agents/skills/`.
