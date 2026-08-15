---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK050
aliases:
- TIK050
name: Separate Ticketscli Distribution From Agent Skill Consumption
ticket_status: '[[Backlog]]'
ticket_priority: Medium
ticket_rank: 10
ticket_created: '2026-07-19T15:47:00Z'
ticket_updated: '2026-08-15T08:32:04Z'
ticket_completed: null
---
# Introduction

Decouple the tickets CLI distribution channel from how agent skills invoke it. Currently every skill invokes the CLI via `npx @aleisium/tickets@latest`, which hard-couples consumption to npm. After this change, skills invoke `tickets` from PATH, and deploying the CLI into PATH becomes a prerequisite for using the skills. This enables distribution via non-npm channels (GitHub Packages, direct download, future Rust binary) without touching skill definitions.

# Requirements

- Agent skills must invoke the CLI as `tickets` (from PATH) instead of `npx @aleisium/tickets@latest`
- Skill documentation must state that installing the CLI into PATH is a prerequisite for using the skills
- The `About Tickets System` preamble in every skill must be updated to reflect the new invocation method
- Skill-specific invocation examples (e.g., `npx @aleisium/tickets@latest list -l 1`) must use `tickets` directly
- The change must not alter any skill's functional behavior — only the invocation mechanism

# Technical Solution

Remove all hard-coded npm package references from the skill files in `.apm/skills/`:

- In the `About Tickets System` preamble of each skill, replace `Always invoke it using \`npx @aleisium/tickets@latest\`` with `Invoke it using the \`tickets\` command (must be installed in PATH). Installing the CLI from a distribution channel is a prerequisite for using the skills.`
- In skill bodies, replace every concrete `npx @aleisium/tickets@latest <subcommand>` invocation with the bare `tickets <subcommand>` equivalent
- No changes to the CLI itself, `package.json`, or workflow files — this is purely a documentation/instruction change in the skill files

# Execution Plan

- [ ] Update `tickets-create/SKILL.md`: replace npx preamble and invocation
- [ ] Update `tickets-list/SKILL.md`: replace npx preamble
- [ ] Update `tickets-review/SKILL.md`: replace npx preamble and `npx @aleisium/tickets@latest list -l 1` invocation
- [ ] Update `tickets-transition/SKILL.md`: replace npx preamble and invocation
- [ ] Update `tickets-rank/SKILL.md`: replace npx preamble and invocation
- [ ] Update `tickets-init/SKILL.md`: replace npx preamble
- [ ] Update `tickets-execution-plan/SKILL.md`: replace npx preamble
- [ ] Re-sync `.agents/skills/` from `.apm/skills/` via APM
- [ ] Verify all skills load without npx references via `grep -r "npx @aleisium/tickets" .agents/skills/`