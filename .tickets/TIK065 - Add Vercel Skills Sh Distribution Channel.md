---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK065
aliases:
  - TIK065
name: Add Vercel Skills Sh Distribution Channel
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 21
ticket_created: 2026-08-16T09:52:27Z
ticket_updated: 2026-08-16T09:52:27Z
ticket_completed:
---
# Introduction

Agent skills are currently distributed only through the APM channel (`.apm/` published via the `publish-apm.yaml` workflow). This ticket adds a second, parallel distribution channel that serves the skills through Vercel's skills.sh, giving users an alternative installation path without affecting the existing APM distribution.

# Requirements

- Publish the agent skills (sourced from `.apm/skills/`) through Vercel skills.sh as a distribution channel in parallel to the existing APM channel
- The APM channel must continue to function unchanged (existing `publish-apm.yaml` behavior, versioning, and tagging preserved)
- The skills.sh distribution must be automatically updated when skill content changes, via CI rather than manual steps
- Each skill must remain installable through the skills.sh channel with its name and content intact
- Document the new channel alongside the existing distribution documentation (APM and npm) in `Tickets System.md`

# Technical Solution

The new channel mirrors the existing APM distribution: a CI workflow (parallel to `publish-apm.yaml`) deploys the skills to Vercel's skills.sh on changes to skill content (`.apm/skills/**`), while the APM workflow continues to tag and push. The exact workflow shape, Vercel deployment target, and skill URL layout are to be determined during implementation.

# Execution Plan

TODO 