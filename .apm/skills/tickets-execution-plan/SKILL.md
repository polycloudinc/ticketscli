---
name: tickets-execution-plan
description: Use when the user asks to create, update, or check off execution plan items in a ticket. Do not use for listing, creating, updating ticket status, ranking, kanban, or reviewing tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter declaring `api: polycloudinc/ticketscli/v1` and containing fields such as `ticket_code`, `ticket_name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `backlog` (unscheduled), `ready` (scheduled), `inprogress` (active work), `complete` (done), `duplicate`, and `wontfix`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, `statistics`, and `migrate` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Execution Plan

Create a linear checkbox list of tasks under an `# Execution Plan` heading. Use `- [ ]` for pending and `- [x]` for completed tasks.

## Phases

Break tasks into separate phases (each a level-three heading `## Phase Name`) when:

- The total number of tasks **exceeds 5**, or
- Tasks touch **logically different parts of the system** that can be completed and tested individually — each distinct component becomes its own phase.

## Format

```markdown
# Execution Plan

## Phase Name

### Tasks
- [ ] Task description
- [ ] Task description

### Verification Steps
- [ ] validation step description

## Phase Name

### Tasks
- [x] Completed task
- [ ] Pending task

### Verification Steps
- [ ] validation step description
```

## Verification Steps

When an execution plan uses multiple phases, every phase must include at least one verification step. A verification step is a **deterministic check** that the solution as of the conclusion of that phase satisfies the phase goals.

Verification step types, in descending order of preference:

1. **Automated unit tests** — idiomatic for the tech stack (e.g., JUnit for Java, pytest for Python, `go test` for Go). Implement these using the project's existing test framework.
2. **Automated integration tests** — tests that exercise multiple components together, using the project's existing test infrastructure.
3. **Smoke tests** — sweeping end-to-end tests that exercise the full workflow. Smoke tests must be **scripted for repeatability**; never execute them ad hoc. In the absence of a prevailing pattern, place smoke test scripts in a `tests/` directory at the project root.

Verification steps go under a `### Verification Steps` sub-heading within the phase (distinct from the `### Tasks` sub-heading). Each verification step is a checklist item such as `- [ ] run pytest tests/test_foo.py`.

### Execution Rules

- **Validate before proceeding.** Confirm each verification step passes before starting work on the next phase.
- **Pause on failure.** If a verification step fails, pause work and report the failure. Do not continue to the next phase until the verification step passes.
