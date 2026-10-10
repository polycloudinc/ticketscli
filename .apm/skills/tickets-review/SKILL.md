---
name: tickets-review
description: Use when the user asks to review a ticket against the current state of the codebase, or says "review next ticket" to review the highest-ranked upcoming ticket. The skill handles reviewing a specific ticket by name/code, reviewing the current ticket, and reviewing the next highest-ranked ticket. Do not use for creating, ranking, kanban, or updating ticket status.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter declaring `api: polycloudinc/ticketscli/v1` and containing fields such as `ticket_code`, `ticket_name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `backlog` (unscheduled), `ready` (scheduled), `inprogress` (active work), `complete` (done), `duplicate`, and `wontfix`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, `statistics`, and `migrate` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Review Ticket

Read the ticket file and review it against the current state of the codebase and relevant project documentation or conventions. Review the ticket's Requirements, Technical Solution, and Execution Plan, and report concrete issues that affect clarity, consistency, implementation alignment, or readiness.

## Review Procedure

1. Read the full ticket, including its status, requirements, technical solution, and execution plan.
2. Inspect relevant implementation, tests, and project documentation to assess whether the ticket aligns with the current project state.
3. Identify missing decisions, ambiguous scope, contradictions within the ticket or with project conventions, mismatches with the codebase, and incomplete or unverifiable execution-plan tasks when present.
4. Report how each issue affects the work and distinguish issues that block implementation from non-blocking observations in the Readiness section.
5. If no issues are found, state that explicitly and indicate readiness based on the ticket and codebase.

This skill is read-only. Do not modify the ticket, code, or other project files while reviewing. Do not create tickets, rank tickets, operate kanban, transition ticket statuses, or edit execution plans.

Respond in three sections:

**Ticket Status**

The ticket code, name, and current status in the format `<ID> - <Name> - <Status>` (status as plain text, no brackets or quotes).

**Open Issues**

If issues are found, present all of them using the `Issue N` number in the bold caption; do not put an additional ordered-list number before the caption. Each issue follows this format:

**Issue 1: Brief Title**

A concise summary of the issue and its impact, aligned with the left margin.

Options:
- A concrete option for addressing the issue.

Use the matching sequential number in the bold caption (`Issue 1`, `Issue 2`, and so on). Follow the caption with a separate, left-aligned summary paragraph. Follow that summary with a separate, plain-text `Options:` caption and a bullet list of the solutions the agent identifies. Keep each option distinct and concise. If there is only one option, show it as a single bullet. Do not label one option as the recommendation; present possible resolutions neutrally.

Example with multiple issues and differing numbers of options:

**Issue 1: Missing Verification Criteria**

The plan does not define how to confirm the requirement is met, making completion difficult to verify.

Options:
- Add a deterministic verification step to the execution plan.

**Issue 2: Conflicting Requirements**

Two requirements prescribe incompatible outcomes, so implementation cannot satisfy both as written.

Options:
- Revise one requirement to remove the conflict.
- Split the requirements into separate behaviors with explicit conditions.

If no issues are identified, output:

**No issues identified.**

**Readiness**

A one-liner stating whether the ticket appears ready to be worked or not. Explicitly distinguish blockers from non-blocking observations.

## Optional Issue Walkthrough

After completing the full report, if one or more issues were found, ask the user exactly:

> Want me to step through these one-by-one?

If there are no issues, do not ask this question. If the user declines, end after the full report.

If the user agrees:

1. Revisit the reported issues in order, presenting only one issue at a time with its caption and summary.
2. Ask how the user wants to proceed on that issue. Present each solution from its **Options:** list as a selectable choice and allow the user to enter their own alternative text through the question's custom response.
3. Wait for the user's choice or alternative before presenting the next issue. Do not treat an option selection as authorization to modify files; this skill remains read-only.
4. After all issues have been discussed, briefly recap the user's choices.

## Review Next Ticket

When the user says "review next ticket" and no specific ticket code or name is provided:

1. Run `npx @polycloudinc/ticketscli@latest list -l 1` to get the single highest-ranked ticket.
2. Take the first ticket from the output (the one with the lowest `ticket_rank` value).
3. Read that ticket file and review it using the standard procedure above.
