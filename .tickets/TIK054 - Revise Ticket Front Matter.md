---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK054
aliases:
- TIK054
name: Revise Ticket Front Matter
ticket_status: '[[Backlog]]'
ticket_priority: Medium
ticket_rank: 4
ticket_created: '2026-08-15T16:56:25Z'
ticket_updated: '2026-08-16T01:43:21Z'
ticket_completed: null
---
# Introduction

The ticket front matter has accumulated Obsidian-style conventions — wiki-link values, template/kind/tags/aliases properties — that add noise and coupling to a Plain-Text-focused ticket system. Revise the front matter to a minimal, flat schema using plain values so tickets are simple, portable, and free of Obsidian-specific conventions.

# Requirements

- The front matter schema must contain only the minimal set of fields the CLI actually needs (identity, status, priority, rank, timestamps), with no decorative or tool-specific properties
- Obsidian-specific properties (`template`, `kind`, `tags`, `aliases`) must be removed from the template and from all tickets
- Wiki-link syntax (e.g. `[[Backlog]]`, `[[Ticket]]`) must be replaced with plain values (e.g. `Backlog`) everywhere
- All CLI subcommands (`create`, `list`, `transition`, `rank`, `validate`, `statistics`, `kanban`) must read, write, and validate the simplified schema
- All existing tickets must be migrated to the simplified schema without losing status, priority, rank, or timestamp data
- Documentation (`Tickets.md`) and agent skills must describe the simplified schema

# Technical Solution

TODO

# Execution Plan

TODO 