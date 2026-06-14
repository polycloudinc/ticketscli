---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK033
aliases:
  - TIK033
name: Update Skills About MD With Full CLI Subcommand List
ticket_status: "[[Ready]]"
ticket_priority: Medium
ticket_rank: 2
ticket_created: 2026-06-14T07:23:09Z
ticket_updated: 2026-06-14T08:32:03Z
ticket_completed: 
---
# Introduction

Update the canonical `SKILL-ABOUT.md` to list all available CLI subcommands (`list`, `validate`, `create`, `transition`, `rank`) and propagate the change to all five agent skills via `update-about.sh`, ensuring every skill's About section consistently reflects the full CLI surface.

# Requirements

- The `SKILL-ABOUT.md` source file at `als-tickets-skill/als-tickets-skill-content/SKILL-ABOUT.md` lists all five CLI subcommands: `list`, `validate`, `create`, `transition`, and `rank`.
- The About section no longer differs between skills (currently `transition-ticket` mentions `transition` while the other four skills do not).
- The `update-about.sh` script is run to synchronize the updated About section into all five skill files under `.apm/skills/`.
- Each skill's `SKILL.md` frontmatter and instructional body remain unchanged — only the shared About section is updated.
- The `transition-ticket` skill's manually-edited About section is not lost; the canonical source is now correct so the sync properly reflects it.

# Technical Solution

TODO

# Execution Plan

TODO 