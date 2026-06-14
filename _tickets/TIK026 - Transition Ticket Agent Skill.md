---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK026
aliases:
  - TIK026
name: Transition Ticket Agent Skill
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-14T04:59:46Z
---
# Introduction

Create an agent skill that uses the `tickets transition` CLI command to move tickets between statuses, handling the built-in rank management rules when transitioning to or from done statuses.

# Requirements

- An agent skill file exists at `.apm/skills/transition-ticket/SKILL.md` (synced to `.agents/skills/transition-ticket/SKILL.md`)
- The skill is listed in the AGENTS.md available skills with a matching description and invocation trigger
- The skill loads on trigger phrases such as "transition ticket", "move ticket", or "change ticket status"
- The user's message includes both the ticket identifier (typically the ticket code, e.g. TIK012) and the target status
- The skill extracts the ticket code and target status from the user's message
- The skill invokes `bash tickets.sh transition -t <code> -T <status>` to perform the transition
- The skill reports the transition result to the user after completion

# Technical Solution

TODO

# Execution Plan

- [ ] Create `.apm/skills/transition-ticket/SKILL.md` with frontmatter and instructions for using the `transition` CLI
- [ ] Sync the skill to `.agents/skills/transition-ticket/SKILL.md`
- [ ] Update `Tickets.md` Agent Skills table with the new transition-ticket skill
- [ ] Test the skill by asking the agent to transition a ticket