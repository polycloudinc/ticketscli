---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK022
aliases:
  - TIK022
name: Accept Review Next Ticket Trigger Phrase
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank:
ticket_created: 2026-06-14T04:07:47Z
ticket_updated: 2026-06-14T05:45:20Z
ticket_completed: 2026-06-14T05:45:20Z
---
# Introduction

Amend the review-ticket agent skill to support the trigger phrase "review next ticket", which automatically identifies the highest-ranked upcoming ticket and reviews it using the standard review process. The skill handles review of a specific ticket by name/code, review of the current ticket, and review of the next highest-ranked ticket via "review next ticket".

# Requirements

- Accept "review next ticket" as a trigger phrase for the review-ticket agent skill
- Update the skill description in the YAML frontmatter so the agent understands the skill applies to: reviewing a specific ticket by name/code, reviewing the current ticket, and reviewing the next highest-ranked ticket
- When the "review next ticket" trigger is used, locate the next top-priority ticket by running `bash tickets.sh list --group backlog` and taking the first result (the ticket with the lowest `ticket_rank` value)
- Exclude terminal statuses from consideration: `[[Complete]]`, `[[Won't Fix]]`, `[[Duplicate]]`. Only `[[Backlog]]`, `[[Ready]]`, and `[[In Progress]]` tickets qualify as candidates.
- Review the identified ticket against the current state of the codebase following the existing review procedure
- Report findings using the standard three-section format (Ticket Status, Open Issues, Readiness)

# Technical Solution

Depends on TIK023 (fixing `--group backlog` to include Ready and In Progress tickets).

Edit `.agents/skills/review-ticket/SKILL.md`:

- Update the `description` field in the YAML frontmatter to cover all accepted triggers: reviewing a specific ticket by name/code, reviewing the current ticket, and reviewing the next highest-ranked ticket
- Add a new section under `# Review Ticket` describing the "review next ticket" flow:
  - When triggered and no ticket code/name is provided, run `bash tickets.sh list --group backlog`
  - Take the first ticket from the output (lowest `ticket_rank` value)
  - Read that ticket file and proceed with the standard review process

Future enhancement (not required for this ticket): a `--limit` flag on the list command to return only the top N tickets, reducing overhead when only the first result is needed.

# Execution Plan

- [x] Update the `description` field in `.agents/skills/review-ticket/SKILL.md` frontmatter
- [x] Add `## Review Next Ticket` section to the skill with the three-step flow 