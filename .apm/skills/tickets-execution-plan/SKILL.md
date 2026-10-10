---
name: tickets-execution-plan
description: Use when the user asks to create, update, or check off execution plan items in a ticket. Do not use for listing, creating, updating ticket status, ranking, kanban, or reviewing tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter declaring `api: polycloudinc/ticketscli/v1` and containing fields such as `ticket_code`, `ticket_name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `backlog` (unscheduled), `ready` (scheduled), `inprogress` (active work), `complete` (done), `duplicate`, and `wontfix`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, `statistics`, and `migrate` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Execution Plan

Create a linear checkbox list of tasks under an `# Execution Plan` heading. Use `- [ ]` for pending and `- [x]` for completed tasks. Every plan must distinguish verifications the agent performs from procedures a human can execute.

## Phases

Break tasks into separate phases (each a level-two heading `## Phase Name`) when:

- The total number of tasks **exceeds 5**, or
- Tasks touch **logically different parts of the system** that can be completed and tested individually — each distinct component becomes its own phase.

## Format

Every plan includes `Tasks`, `Agent Verifications`, and `Human Verification Steps` sections. Use the single-plan form when the phase-splitting rules do not apply. Use the phased form when they do; each phase has all three sections.

Keep a blank line before and after each Markdown heading. Tasks and agent verifications are checklist items. Each human verification is its own Markdown heading with the appropriate heading level shown below.

````markdown
# Execution Plan

## Tasks

- [ ] Task description

## Agent Verifications

- [ ] VA01: Deterministic check performed by the agent; expected result: observable outcome.

## Human Verification Steps

### VH01: Human Verification Name

Prerequisites and working directory: state required setup and where to run commands.

Instructions:
1. First action for the human.
2. Next action for the human.

Commands (run from the stated working directory, one at a time):

```sh
one copy-pasteable command
```

```sh
another command, if needed
```

Expected result: describe how the human can recognize success.

## Phase 1: Phase Name

### Tasks

- [ ] Task description

### Agent Verifications

- [ ] VA01: Deterministic check performed by the agent; expected result: observable outcome.

### Human Verification Steps

#### VH01: Human Verification Name

Prerequisites and working directory: state required setup and where to run commands.

Instructions:
1. First action for the human.
2. Next action for the human.

Commands (run from the stated working directory, one at a time):

```sh
one copy-pasteable command
```

Expected result: describe how the human can recognize success.
````

## Agent Verifications

Every plan must contain at least one deterministic agent verification. Every phase must contain at least one agent verification that confirms the phase goals are met. State the expected result for each check. Agent verifications are checks for the agent to perform; do not present a human-only procedure as an agent check.

Verification types, in descending order of preference:

1. **Automated unit tests** — idiomatic for the tech stack (e.g., JUnit for Java, pytest for Python, `go test` for Go). Implement these using the project's existing test framework.
2. **Automated integration tests** — tests that exercise multiple components together, using the project's existing test infrastructure.
3. **Smoke tests** — sweeping end-to-end tests that exercise the full workflow. Smoke tests must be **scripted for repeatability**; never execute them ad hoc. In the absence of a prevailing pattern, place smoke test scripts in a `tests/` directory at the project root.

Put agent checks under `## Agent Verifications` in a single-plan format, or `### Agent Verifications` within each phase. Write each as a checklist task whose text begins with its code, for example `- [ ] VA01: run pytest tests/test_foo.py; expected result: all tests pass`.

## Human Verification Steps

Provide at least one human verification procedure in a single-plan format and in every phase. Each procedure must have its own Markdown heading (`###` in the single-plan format, `####` within a phase), with a unique code and descriptive name at the beginning, for example `#### VH01: Verify the rendered workflow`.

Each human verification must include:

- Prerequisites and working directory.
- Ordered, step-by-step instructions, flush-left and not nested or indented under a list.
- One or more copy-pasteable commands needed to conduct the check. Put every command in its own fenced code block; never combine multiple commands in one block. Keep command labels and fences flush-left, outside lists, so Markdown tools can provide a single-click copy action.
- An expected result that explains how to recognize success.

## Verification Codes

Give every verification a unique code within the ticket's execution plan. Agent verification codes use `VA` followed by a two-digit sequence (`VA01`, `VA02`, …) and appear at the beginning of the verification checklist task. Human verification codes use `VH` followed by a two-digit sequence (`VH01`, `VH02`, …) and appear at the beginning of the human verification heading. Number each type sequentially from `01` across the whole plan; do not reuse or restart codes between phases.

### Execution Rules

- **Validate before proceeding.** The agent runs all agent verification checks for a phase and confirms they pass before starting work on the next phase.
- **Pause on failure.** If an agent verification fails, pause work and report the failure. Do not continue to the next phase until it passes.
- **Keep human checks distinct.** Human verification procedures are provided for the human to execute. Do not claim to have performed them; report their codes and exact commands so the human can run them.
