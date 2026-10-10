---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK068
ticket_name: Make Review Skill More Helpful
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 22
ticket_created: 2026-10-10T03:49:56Z
ticket_updated: 2026-10-10T05:36:48Z
ticket_completed:
---
# Introduction

Refine the ticket review skill so reviews assess ticket clarity and readiness against the relevant codebase and project conventions more consistently. The skill should give users actionable findings while preserving its focused, read-only review role.

# Requirements

- The review evaluates ticket requirements, technical solution, and execution plan against the current codebase and relevant project documentation or conventions
- Reviews identify missing decisions, scope ambiguity, internal contradictions, implementation mismatches, and incomplete or unverifiable execution plans when present
- Each issue is presented with a bold caption in the exact format `Issue N: Brief Title`, without an additional number preceding the caption, followed by a left-aligned summary paragraph explaining the issue and its impact
- After the summary, each issue has a separate plain-text `Options:` caption followed by a bullet list of the solutions the agent can think of; when there is only one option, it is still shown as a single bullet
- After presenting all issues, the review asks the user exactly: `Want me to step through these one-by-one?`
- If the user agrees, the agent presents the issues again one at a time and asks how to proceed on each issue before moving to the next
- For each issue in the step-through, the agent presents the issue's options as selectable items and includes an option for the user to enter their own alternative text
- If the user declines the step-through, the review ends after presenting the complete issue list and readiness assessment
- Readiness clearly distinguishes issues that block implementation from non-blocking observations
- The existing response sections and ticket status format remain consistent, and reviews do not modify ticket or code files
- The skill remains limited to reviewing tickets and does not take on ticket creation, ranking, kanban, status transitions, or execution-plan editing

# Technical Solution

TODO

# Execution Plan

## Phase 1: Review Criteria And Scope

### Tasks

- [x] Review the current `tickets-review` skill and identify gaps in its review criteria and scope
- [x] Refine the canonical `.apm/skills/tickets-review/SKILL.md` instructions to compare ticket requirements, technical solution, and execution plan with the current codebase and project conventions, and to distinguish blocking issues from non-blocking observations
- [x] Preserve the skill's review-only responsibilities and existing response sections
- [x] Update `Tickets System.md` documentation
- [x] Synchronize the skill to `.agents/skills/` through APM

### Verification Steps

- [x] Verify the canonical skill explicitly covers each review criterion and excluded responsibility in the ticket requirements, and confirm the synchronized `.agents/skills/tickets-review/SKILL.md` matches the canonical source

## Phase 2: Issue Report Format

### Tasks

- [x] Format each reported issue with a bold `Issue N: Brief Title` caption, no preceding list number, and a left-aligned summary paragraph describing the issue and impact
- [x] Follow each issue summary with a plain-text `Options:` caption and a bullet for every solution the agent identifies, including a single bullet when only one option exists
- [x] Preserve the ticket status and readiness sections and the no-issues response
- [x] Document the issue report format in `Tickets System.md`

### Verification Steps

- [x] Check sample review outputs with one issue/one option and multiple issues/multiple options against the required captions, paragraph separation, numbering, and bullets
- [x] Check a no-issues sample retains the no-issues and readiness responses without fabricating issue options

## Phase 3: Opt-In Issue Walkthrough

### Tasks

- [x] After presenting all issues and readiness, ask exactly `Want me to step through these one-by-one?` when issues are present
- [x] On user agreement, present issues again one at a time with their options as selectable choices and an input for user-provided alternative text; wait for a response before moving to the next issue
- [x] If the user declines, finish after the complete initial issue list and readiness assessment without modifying ticket or code files
- [x] Document the opt-in issue walkthrough in `Tickets System.md`

### Verification Steps

- [x] Exercise a multi-issue review with agreement, select an option for the first issue and custom alternative text for the next, verifying sequential prompts and no file modifications
- [x] Exercise the same review with declining the walkthrough and verify the initial full report is complete and no per-issue prompt follows
