---
name: tickets-execute
description: Use when the user asks to "execute the ticket", "execute ticket", "run the ticket", "run ticket", or similar. Also use when the user says "reverify" or "revalidate" to rerun verification steps for a phase. Do not use for creating, listing, ranking, reviewing, transitioning, or updating execution plan items in tickets.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Execute Ticket

When the user asks to execute a ticket:

## Pre-flight Check

Read the ticket file. If it does not contain an `# Execution Plan` section with at least one phase or task, respond:

> **No execution plan found.** This ticket cannot be executed until an execution plan is created. Use the tickets-execution-plan skill to add one.

## Phased Execution

Work through the execution plan one phase at a time:

1. For each phase, execute every pending task under `### Tasks` in order.
2. Mark each completed task as `- [x]` in the ticket file as you go.
3. After all tasks in the phase are complete, run every item under `### Verification Steps`.
4. If a verification step fails:
   - Pause and report the failure.
   - Do not proceed to the next phase.
   - Explain what failed and suggest next steps.
5. If all verification steps pass, inform the user and provide instructions for how they can manually repeat the verification themselves. Include the exact commands to run.

## After Each Verified Phase

After a phase passes verification, output:

> Phase **\<Phase Name\>** complete and verified. To re-verify this phase yourself, run: \<command\>

List each verification command from the phase individually.

## Reverify

When the user says "reverify" or "revalidate" (with or without specifying a phase):

1. Identify the phase. If no phase is specified, re-verify the current phase (the last phase with at least one completed task checkmark, or the first phase with pending tasks).
2. Re-run all verification steps for that phase.
3. Report each step as pass or fail.
4. If any step fails, do not proceed.
5. Explain how the user can manually run the verification steps themselves (include exact commands).

## Completion

After all phases are complete and verified, report that execution is finished.
