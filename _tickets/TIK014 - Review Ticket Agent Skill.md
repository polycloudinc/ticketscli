---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK014
aliases:
  - TIK014
name: Review Ticket Agent Skill
subjects: agent
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 14
---

# Introduction

Create an agent skill that provides a short prompt instructing agents to review a ticket against the current state of the codebase and identify any open questions or ambiguities.

# Requirements

- A new skill file must be created at `.apm/skills/review-ticket/SKILL.md` for APM packaging and publishing.
- The skill description must be narrow: it only applies when the user asks to review a ticket.
- The skill must contain a short prompt directing the agent to read the ticket file and review it against the current state of the codebase.
- The response must be structured in three sections:
  1. **Ticket Info**: ticket code, name, and status.
  2. **Open Issues**: a numbered list of open questions, inconsistencies, or mis-alignment with the current state of the code. Each issue must include a short summary of the recommended solution and may offer multiple solution options labelled Option A, Option B, Option C, etc. If no issues are identified, this section must contain the message "No issues identified."
  3. **Readiness**: a one-liner stating whether the ticket appears ready to be worked or not.
- The skill must NOT cover creating tickets, ranking, kanban, or updating ticket status — it is strictly focused on reviewing a ticket for clarity and completeness.

# Technical Solution

Create the `als-tickets-skill/als-tickets-skill-main/.apm/skills/review-ticket/SKILL.md` file following the same APM packaging pattern as the existing `tickets` skill (canonical content under `.apm/`, symlink from `.agents/`). The skill uses frontmatter with `name: review-ticket` and a narrow `description`, followed by a short prompt. The prompt instructs the agent to read the ticket, review it against the codebase, and respond with three sections: ticket info, open issues (with solution options), and a readiness one-liner.

# Execution Plan

- [x] Create the `.apm/skills/review-ticket/` directory within the existing `als-tickets-skill/als-tickets-skill-main/` component.
- [x] Draft the `SKILL.md` content with a short prompt that structures the response into three sections: ticket info, open issues (with solution options), and readiness one-liner.
- [x] Verify the skill description and prompt do not reference creating tickets, ranking, kanban, or updating status.
- [x] Verify the skill is loadable by the agent skill system.
- [x] Verify `tickets list` shows TIK014 after creating it.
