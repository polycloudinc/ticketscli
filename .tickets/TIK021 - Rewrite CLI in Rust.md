---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK021
ticket_name: Rewrite CLI in Rust
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 3
ticket_created: "2026-06-14T03:36:05Z"
ticket_updated: "2026-08-16T01:43:19Z"
ticket_completed:
---
# Introduction

Rewrite the `tickets` CLI from Bash to Rust, producing a single self-contained binary with no external runtime dependencies.

# Requirements

- The Rust CLI must implement all existing subcommands with identical behavior: `list`, `create`, `validate`, `rank`, `rank up`, `rank down`, `rank first`, `rank last`.
- The Rust CLI must also implement any planned subcommands: `transition`.
- Must be a single statically linked binary with no runtime dependency on `bash`, `yq`, `sed`, `column`, or any other external tool.
- Must read and write the same `_tickets/` directory structure, `_tickets/settings.yaml`, and `_templates/Ticket.md` with identical frontmatter and filename conventions.
- Must pass `tickets validate --all` against all existing tickets with no deviations.
- The existing `tickets.sh` symlink at the repo root should be replaced by the Rust binary (or a wrapper invoking it).
- The binary should be publishable via `cargo install` or as a pre-built release artifact.

# Technical Solution

TODO

# Execution Plan

TODO 
