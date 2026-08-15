---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK052
aliases:
- TIK052
name: Add Verification Steps To Execution Plan
ticket_status: '[[Complete]]'
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-08-07T15:47:23Z'
ticket_updated: '2026-08-08T06:23:49Z'
ticket_completed: '2026-08-08T06:23:43Z'
---
# Introduction

Add verification steps to the tickets-execution-plan skill (source: `.apm/skills/tickets-execution-plan/SKILL.md`) so that each phase in an execution plan includes at least one deterministic checkpoint confirming the solution satisfies the phase goals before proceeding.

# Requirements

- Edit `.apm/skills/tickets-execution-plan/SKILL.md` (source directory; `.agents/skills/` is auto-populated by APM install)
- The skill must require at least one verification step per phase when multiple phases are used
- A verification step is a deterministic check that the solution as of the conclusion of that phase satisfies the phase goals
- Verification step types, in descending order of preference:
  - Automated unit tests (idiomatic for the tech stack, e.g., JUnit for Java projects)
  - Automated integration tests
  - Smoke tests (sweeping end-to-end tests; must be scripted for repeatability — never executed ad hoc by the agent; in the absence of a prevailing pattern, place smoke test scripts in a `tests/` directory at the project root)
- The skill must instruct agents to validate each verification step before moving to the next phase
- A verification step that fails must cause the agent to pause and report the issue
- The ticket template already mentions verification steps; the skill instructions must direct agents to include them in practice

# Technical Solution

TODO

# Execution Plan

TODO 