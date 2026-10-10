---
name: tickets-assist-verification
description: Use when the user asks to assist with human verification, walk through manual verification steps, or resume remaining human checks for a ticket.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `.tickets/` directory, each with YAML frontmatter declaring `api: polycloudinc/ticketscli/v1` and containing fields such as `ticket_code`, `ticket_name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `backlog` (unscheduled), `ready` (scheduled), `inprogress` (active work), `complete` (done), `duplicate`, and `wontfix`. A `tickets` CLI provides `init`, `list`, `validate`, `create`, `transition`, `rank`, `statistics`, and `migrate` subcommands for managing tickets.

The `tickets` CLI is published as `@polycloudinc/ticketscli`. Always invoke it using `npx @polycloudinc/ticketscli@latest`.

# Assist With Human Verification

Guide the user through remaining human verification procedures recorded in a ticket's execution plan. The user performs the manual steps and commands; do not claim to have performed them yourself.

## Find Eligible Verifications

1. Use the ticket code or name provided by the user. If they refer to the current ticket, use the ticket established in the conversation. If the ticket is unclear, ask which ticket to use.
2. Read that ticket from `.tickets/` and inspect its `# Execution Plan`.
3. Process human verification sections in execution-plan order. A verification is eligible only when its containing work is complete:
   - In a phased plan, all checkboxes under that phase's `### Tasks` and `### Agent Verifications` must be checked (`- [x]`). Do not offer checks from incomplete phases.
   - In a single-plan format, all checkboxes under `## Tasks` and `## Agent Verifications` must be checked.
4. Identify human verifications by their `VH##` heading. A `Status: Passed` line means the verification is complete and must be excluded. `Status: Pending` means it remains eligible. Treat a missing status line in a legacy ticket as pending.
5. Keep verifications in phase and document order. If no pending verifications are eligible, tell the user there is nothing remaining to verify.

## Ask Before Each Verification

For each eligible pending verification, first show only its code and description, then use a selectable question with these choices:

- **Proceed** — start guiding the user through this verification.
- **Skip** — leave it pending and offer the next eligible verification, if any.
- **Stop** — end the entire assisted-verification session immediately. Do not offer later checks or change any remaining statuses.

Ask this question again for every subsequent eligible verification. Honor a user request to stop or skip while a verification is in progress using the same behavior.

## Guide the User Step by Step

After the user chooses **Proceed**:

1. Present the verification prerequisites and working directory.
2. Present one instruction at a time and wait for the user's response before presenting the next instruction.
3. Present commands one at a time. Put each command in its own flush-left fenced code block; never combine commands in one block or indent command fences under a list. Wait for the user to run the command and report its result before continuing.
4. If the user reports a failure at any step, report that result, leave the verification pending, stop guiding that verification, and ask the selectable question for the next eligible pending verification.
5. After all instructions pass, accept the user's explicit confirmation that the verification passed. If the outcome is unclear, ask the user to report whether it passed or failed.

## Record Outcomes

- Change the verification's `Status: Pending` line to `Status: Passed` only after the user explicitly confirms success. For a legacy verification with no status line, add `Status: Passed` directly below its `VH##` heading only after that confirmation.
- Skipped, stopped, failed, or unconfirmed verifications remain pending. Do not add a pass marker for them.
- Update only the selected verification's status in the ticket; preserve its instructions, commands, and other ticket content.
- After all eligible verifications have been offered or the user stops, summarize which codes passed and which remain pending or were skipped. Never imply that a skipped or stopped verification passed.
