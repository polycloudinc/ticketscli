---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK051
aliases:
- TIK051
name: Curl Bash Install Script
ticket_status: '[[Backlog]]'
ticket_priority: Medium
ticket_rank: 2
ticket_created: '2026-07-24T14:57:26Z'
ticket_updated: '2026-08-16T01:43:20Z'
ticket_completed: null
---
# Introduction

Provide a curl-piped-to-bash install script as an alternative distribution method for the tickets CLI, enabling users to install without any package manager.

# Requirements

- User can install the tickets CLI with a single `curl | bash` command
- The installer downloads `tickets.sh`, `yz.py`, and `Ticket.md` to a user-local bin directory (e.g., `~/.local/bin`)
- The installer makes the scripts executable
- The installer verifies `python3` is available and `pyyaml` is installed, warning the user if either is missing
- The installer prints a clear success message including a reminder to ensure the install directory is on `PATH`

# Technical Solution

TODO

# Execution Plan

TODO