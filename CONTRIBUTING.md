# Contributing

## Development Setup

A devcontainer is provided under `.devcontainer/` (requires Docker and the devcontainer CLI):

- `bash .devcontainer/up.sh` — build and start the devcontainer, then drop into a shell inside it
- `bash .devcontainer/down.sh` — stop and remove the container

The image includes git, python3 with pyyaml, and opencode.

## Ticket-Driven Workflow

All work is tracked as Markdown tickets in `.tickets/`. See `Tickets System.md` for the full specification.

1. List upcoming work with `tickets list` (highest-ranked first).
2. Review the ticket against the codebase and build an execution plan in the ticket.
3. Work the plan phase by phase, checking off tasks in the ticket file as you go.
4. Transition the ticket as it progresses: `tickets transition --ticket TIKnnn --target <status>`.

The CLI is published as `@polycloudinc/ticketscli` (invoke via `npx @polycloudinc/ticketscli@latest`); in this repository you can also run it directly via `./tickets.sh`.

## Commit Conventions

- One ticket per commit; the commit message is the ticket code and name, e.g. `TIK029 - Publish Project As Open Source`.
- `./gitct.sh` infers the commit message from the single staged ticket file under `.tickets/` and prompts for confirmation before committing.
