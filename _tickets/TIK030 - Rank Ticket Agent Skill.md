---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK030
aliases:
  - TIK030
name: Rank Ticket Agent Skill
ticket_status: "[[Ready]]"
ticket_priority: Medium
ticket_rank: 2
ticket_created: 2026-06-14T07:20:15Z
ticket_updated: 2026-06-14T07:46:06Z
ticket_completed: 
---
# Introduction

Create a new `rank-ticket` agent skill that exposes the CLI `rank up`, `rank down`, `rank first`, and `rank last` subcommands to AI agents, allowing users to promote, demote, or reposition tickets in the priority stack via natural language.

# Requirements

- A new `rank-ticket` skill file is created at `.apm/skills/rank-ticket/SKILL.md`.
- The skill handles natural-language phrases such as "promote TIK005", "demote TIK003", "move TIK007 to the top", "send TIK012 to the bottom", "bump TIK004 up", and similar ranking requests.
- The skill maps user phrasing to the correct CLI subcommand: `rank up`, `rank down`, `rank first`, or `rank last`.
- The skill extracts the ticket code from the user's message and invokes `bash tickets.sh rank <subcommand> -t <code>`.
- The skill reports the result (new rank position or "already at highest/lowest priority") back to the user.
- The skill's About section is consistent with the canonical `SKILL-ABOUT.md` and includes all CLI subcommands.
- The skill is listed in the available skills registry (`AGENTS.md` and `Tickets.md` documentation).
- The skill follows the same structure conventions as existing skills (frontmatter with name/description, About section, and instructional body).

# Technical Solution

TODO

# Execution Plan

TODO 