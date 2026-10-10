---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK070
ticket_name: Assist With Human Verification
ticket_status: complete
ticket_priority: Medium
ticket_rank: null
ticket_created: '2026-10-10T07:06:50Z'
ticket_updated: '2026-10-10T08:00:00Z'
ticket_completed: '2026-10-10T07:59:50Z'
---
# Introduction

Add an interactive assisted-verification workflow that guides users through pending human checks from completed ticket phases. The agent offers each check individually and lets the user proceed, skip it, or stop the entire session.

# Requirements

- Implement the capability as an agent skill named `tickets-assist-verification`, stored at `.apm/skills/tickets-assist-verification/SKILL.md` and synchronized into `.agents/skills/` through APM.
- Give the skill frontmatter `name: tickets-assist-verification` and a description that covers requests to assist with human verification.
- The agent discovers human verification sections in completed phases, where all phase tasks and agent verifications are complete, and processes them in ticket order.
- Human verifications already confirmed as passed are excluded; verifications without a recorded pass remain pending.
- Before presenting detailed instructions for a pending verification, show its code and description and ask the user a selectable question with **Proceed**, **Skip**, and **Stop** choices.
- **Stop** ends the entire assisted-verification session immediately without presenting later checks or marking remaining checks complete.
- **Skip** leaves the check pending and moves to the next pending human verification, if any.
- **Proceed** guides the user through the selected verification one instruction at a time, waiting for the user's response before presenting the next instruction or command.
- Present every command in its own flush-left fenced code block for easy copying; do not combine multiple commands in one block.
- Ask the user to report the outcome and record a verification as passed only after the user confirms it passed. Skipped, stopped, failed, or unconfirmed checks must not be marked passed.
- If no pending human verifications are available in completed phases, tell the user there is nothing remaining to verify.
- Keep verification outcomes in the ticket so later assisted-verification runs can resume without repeating checks already confirmed as passed.

# Technical Solution

Create `.apm/skills/tickets-assist-verification/SKILL.md` with `name: tickets-assist-verification` and invocation guidance for assisting with human verification. Read the canonical `VH##` verification sections produced by the execution-plan skill, filter to completed phases, and process eligible checks in plan order using a selectable Proceed/Skip/Stop question before each check. On Proceed, present prerequisites and then each instruction or command individually, awaiting user confirmation between steps. Maintain a per-verification status in the ticket (`Pending` by default, `Passed` only on explicit user confirmation); treat legacy sections without a status as pending and leave skipped, stopped, failed, or unconfirmed checks pending. If the format needs a status marker for newly authored human verifications, update `.apm/skills/tickets-execution-plan/SKILL.md` as the source and synchronize `.agents/skills/` using APM. Use APM to synchronize the new skill into `.agents/skills/tickets-assist-verification/` rather than editing the synchronized copy directly.

# Execution Plan

## Phase 1: Define Human Verification Status

### Tasks

- [x] Update the source execution-plan skill to include `Status: Pending` under each human verification heading in both single-plan and phased templates.
- [x] Define that missing status means pending, and only explicit user confirmation changes a human verification to `Status: Passed`.
- [x] Document that skipped, stopped, failed, or unconfirmed verifications remain pending for later assisted runs.

### Agent Verifications

- [x] VA01: Review the execution-plan skill examples and status rules, then run `git diff --check -- .apm/skills/tickets-execution-plan/SKILL.md`; expected result: both plan forms show the pending marker and the status transition rule is unambiguous, with no whitespace errors.

### Human Verification Steps

#### VH01: Review the Status Marker Format

Status: Pending

Prerequisites and working directory: repository root; the source execution-plan skill has been updated.

Instructions:
1. Open `.apm/skills/tickets-execution-plan/SKILL.md` in a Markdown preview.
2. Confirm both single-plan and phased examples place `Status: Pending` with each human verification heading.
3. Confirm the instructions describe missing markers as pending and passing as requiring explicit user confirmation.

Commands (run from the repository root, one at a time):

```sh
git diff --check -- .apm/skills/tickets-execution-plan/SKILL.md
```

```sh
git diff -- .apm/skills/tickets-execution-plan/SKILL.md
```

Expected result: there are no whitespace errors, and the rendered examples make the initial and passed states clear.

## Phase 2: Implement the Assisted Verification Skill

### Tasks

- [x] Create `.apm/skills/tickets-assist-verification/SKILL.md` with `name: tickets-assist-verification` and an invocation description for user requests to assist with human verification.
- [x] Implement discovery in plan order for pending `VH##` checks in completed phases and completed single-plan execution plans; treat absent status as pending and omit checks marked passed.
- [x] Add the selectable **Proceed**, **Skip**, and **Stop** prompt; implement stop as ending the whole session and skip as leaving the check pending and advancing.
- [x] On Proceed, present prerequisites and each instruction or command individually, waiting for the user's response between steps; place every command in its own flush-left fenced code block.
- [x] Record `Status: Passed` only after explicit user confirmation; when a step fails, report it, leave the verification pending, and ask the selectable question for the next pending verification.
- [x] Document the new skill and its assisted-verification workflow in `Tickets System.md`.
- [x] Run `apm install` to synchronize the new skill into `.agents/skills/`.

### Agent Verifications

- [x] VA02: Compare the source and APM-synchronized skill files and run `git diff --check`; expected result: the skill name, eligibility rules, choice behavior, step-by-step interaction, and outcome rules are present in matching files with no whitespace errors.

### Human Verification Steps

#### VH02: Review the Assisted Verification Workflow

Status: Pending

Prerequisites and working directory: repository root; APM synchronization has completed.

Instructions:
1. Open `.agents/skills/tickets-assist-verification/SKILL.md` in a Markdown preview.
2. Confirm the Proceed/Skip/Stop question appears before detailed verification instructions and stop/skip behavior is distinct.
3. Confirm instructions are presented one at a time, each command is individually copyable, and only explicit user-confirmed passes are recorded.
4. Confirm completed single-plan checks and checks from completed phases are eligible, while passed checks and checks in incomplete phases are excluded.

Commands (run from the repository root, one at a time):

```sh
diff -u .apm/skills/tickets-assist-verification/SKILL.md .agents/skills/tickets-assist-verification/SKILL.md
```

```sh
git diff --check -- .apm/skills/tickets-assist-verification/SKILL.md .agents/skills/tickets-assist-verification/SKILL.md
```

Expected result: the file comparison is empty, the whitespace check passes, and the rendered commands have individual copy controls.
