---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK028
aliases:
  - TIK028
name: Serve Subcommand for Web Admin and Kanban View
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 4
ticket_created: 2026-06-14T07:13:21Z
ticket_updated: 2026-06-14T08:52:28Z
ticket_completed:
---
# Introduction

Add a `serve` subcommand to the tickets CLI that starts a local web server hosting a graphical web UI for administering tickets, with a kanban board view showing tickets grouped by status columns.

# Requirements

- `tickets serve` starts a local HTTP server and opens the web UI in the default browser.
- The web UI provides a kanban board view with columns for Backlog, Ready, In Progress, and Complete statuses, displaying ticket subject lines and codes in each column.
- The web UI supports creating new tickets through a form that populates all required frontmatter fields.
- The web UI supports transitioning tickets between statuses via drag-and-drop between kanban columns.
- The web UI supports inline editing of ticket fields (name, priority, rank) directly from the kanban board.
- The web UI supports a list/table view as an alternative to the kanban board, with sorting and filtering.
- The web UI reflects live data by re-reading tickets from the `_tickets/` directory.
- All server-side operations (CRUD, transition, re-rank) are implemented as REST API endpoints that call into the existing ticket manipulation logic.
- The server and static assets (HTML, CSS, JS) are fully self-contained within the tickets CLI; no external web framework dependencies beyond what is already available.

# Technical Solution

TODO

# Execution Plan

TODO 