---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK069
ticket_name: Extend Execution Plan Verification Guidance
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 23
ticket_created: 2026-10-10T05:50:03Z
ticket_updated: 2026-10-10T05:50:03Z
ticket_completed:
---
# Introduction

Extend the execution plan skill so plans specify checks for the agent to perform as well as verification procedures for a human. Standardize the structure and make human procedures directly usable, including individually copyable command blocks.

# Requirements

- Execution plans distinguish agent-performed verifications from human-executed verification procedures.
- The skill defines a consistent Markdown structure for the execution plan heading, phases, tasks, agent verifications, and human verification steps.
- Each phase presents its tasks, agent verifications, and human verification steps in distinct, consistently named sections.
- Every verification has a unique code within the ticket: agent verifications use sequential `VA##` codes and human verifications use sequential `VH##` codes; codes do not restart between phases.
- Agent verification codes appear at the beginning of the task text in the form `VA01: Description`.
- Human verification codes appear at the beginning of each human verification section heading in the form `VH01: Description`.
- Agent verifications specify deterministic checks for the agent to run and the expected result; retain the existing guidance to validate a phase before proceeding and pause on failed checks.
- Every human verification includes ordered, step-by-step instructions, copy-pasteable command(s), and the expected result so a human can conduct the check independently.
- Each command in a human verification is placed in its own fenced code block, with no multiple commands combined in a single block, to support single-click copying in rendered Markdown tools.
- Human verification instructions, command labels, and command fences are flush-left (not nested or indented under list items) so instructions render plainly and commands remain individually copyable.
- Human verification instructions identify any required working directory or prerequisites and explain how to recognize success.
- Preserve the existing guidance on when to split work into phases and the preference for automated, repeatable agent checks.

# Technical Solution

Update `.apm/skills/tickets-execution-plan/SKILL.md`, the source skill file, with the verification distinctions and canonical Markdown layout below. Preserve the existing rules for when to split work into phases. Use the single-plan form when those rules do not call for phases; use the phased form when they do. Every plan (and every phase) has separate task, agent verification, and human verification sections. Do not edit the synchronized `.agents/skills/` copy directly.

````markdown

# Execution Plan

<!-- Single-plan form when phases are not needed -->

## Tasks

- [ ] <task>

## Agent Verifications

- [ ] VA01: <deterministic check the agent performs>; expected result: <observable outcome>

## Human Verification Steps

### VH01: <Human Verification Name>

Prerequisites and working directory: <details>

Instructions:
1. <action>
2. <action>

Commands (run from <working directory>, one at a time):

```sh
<one copy-pasteable command>
```

```sh
<another command, if needed>
```

Expected result: <observable outcome>

<!-- Phased form when the phase-splitting rules apply; repeat for each phase and continue verification codes across phases -->

## Phase 1: <phase name>

### Tasks

- [ ] <task>

### Agent Verifications

- [ ] VA01: <deterministic check the agent performs>; expected result: <observable outcome>

### Human Verification Steps

#### VH01: <Human Verification Name>

Prerequisites and working directory: <details>

Instructions:
1. <action>
2. <action>

Commands (run from <working directory>, one at a time):

```sh
<one copy-pasteable command>
```

Expected result: <observable outcome>
````

Each human verification step must include ordered instructions, its prerequisites or working directory, expected results, and any commands needed to perform it. Put every command in its own fenced code block so Markdown tools can provide a single-click copy action; never combine multiple commands in one block.

# Execution Plan

## Phase 1: Update the Source Skill

### Tasks

- [x] Update `.apm/skills/tickets-execution-plan/SKILL.md` with canonical single-plan and phased Markdown layouts that separate tasks, agent verifications, and human verification steps while preserving the phase-splitting criteria.
- [x] Define deterministic agent checks, expected outcomes, and the rule to pass each phase's agent verifications before proceeding.
- [x] Define ticket-wide sequential `VA##` and `VH##` codes and human verification procedures with prerequisites, step-by-step flush-left instructions, expected outcomes, and one unindented fenced block per copy-pasteable command.

### Agent Verifications

- [x] VA01: Review the source skill against TIK069 and run `git diff --check`; expected result: both plan forms, verification roles, code conventions, and human command formatting are represented without whitespace errors or conflicts with existing phase-splitting rules.

### Human Verification Steps

#### VH01: Review the Source Skill Format

Prerequisites and working directory: repository root.

Instructions:
1. Open `.apm/skills/tickets-execution-plan/SKILL.md` in a Markdown preview after the source skill is updated.
2. Confirm the examples distinguish agent checks from human procedures and show the required verification codes.
3. Confirm human instructions and command blocks are flush-left, with each command in a separate fenced block.

Commands (run from the repository root, one at a time):

```sh
git diff --check -- .apm/skills/tickets-execution-plan/SKILL.md
```

```sh
git diff -- .apm/skills/tickets-execution-plan/SKILL.md
```

Expected result: the diff has no whitespace errors and the rendered examples are clear and copyable.

## Phase 2: Synchronize and Validate the Skill

### Tasks

- [x] Run `apm install` from the repository root to synchronize the source skill into `.agents/skills/`.
- [x] Compare `.apm/skills/tickets-execution-plan/SKILL.md` with `.agents/skills/tickets-execution-plan/SKILL.md` to confirm APM synchronized the source.
- [x] Review the synchronized skill and confirm the verification examples render as intended.

### Agent Verifications

- [x] VA02: Compare the source and synchronized skill files and run `git diff --check`; expected result: the files match and no whitespace errors are reported.

### Human Verification Steps

#### VH02: Verify the Installed Skill and Rendered Examples

Prerequisites and working directory: repository root; APM synchronization has completed.

Instructions:
1. Confirm the source and installed skill copies match by running the first command below.
2. Check the second command's output for whitespace errors.
3. Open `.agents/skills/tickets-execution-plan/SKILL.md` in a Markdown preview and verify headings have blank lines around them, verification codes are visible, and each human command has its own copyable code block.

Commands (run from the repository root, one at a time):

```sh
diff -u .apm/skills/tickets-execution-plan/SKILL.md .agents/skills/tickets-execution-plan/SKILL.md
```

```sh
git diff --check -- .apm/skills/tickets-execution-plan/SKILL.md .agents/skills/tickets-execution-plan/SKILL.md
```

Expected result: the file comparison is empty, the whitespace check passes, and the rendered human verification commands are individually copyable.
