# Contributing

## Development Setup

A devcontainer is provided under `.devcontainer/` (requires Docker and the devcontainer CLI):

- `bash .devcontainer/up.sh` — build and start the devcontainer, then drop into a shell inside it
- `bash .devcontainer/down.sh` — stop and remove the container

The image includes git, python3 with pyyaml, the APM CLI, and opencode.

## Ticket-Driven Workflow

All work is tracked as Markdown tickets in `.tickets/`. See `Tickets System.md` for the full specification.

1. List upcoming work with `tickets list` (highest-ranked first).
2. Review the ticket against the codebase and build an execution plan in the ticket.
3. Work the plan phase by phase, checking off tasks in the ticket file as you go.
4. Transition the ticket as it progresses: `tickets transition --ticket TIKnnn --target <status>`.

The CLI is published as `@polycloudinc/ticketscli` (invoke via `npx @polycloudinc/ticketscli@latest`); in this repository you can also run it directly via `./tickets.sh`.

## Commit Conventions

- Associate each commit with one ticket where possible. A ticket may be represented by multiple commits when that improves clarity.
- Ancillary changes that are unrelated to a ticket may be committed separately without a ticket number.
- New ticket-associated commit messages use the ticket code followed by a short summary without a dash, e.g. `TIK029 Publish Project As Open Source`.
- New future-work tickets and ticket metadata changes from status transitions belong in a final `Backlog grooming` commit when they are part of the same commit series.
- `./gitct.sh` infers the no-dash commit message from one staged ticket file and prompts for confirmation. Use a direct `git commit` command for ancillary commits or grouped backlog-grooming changes.
