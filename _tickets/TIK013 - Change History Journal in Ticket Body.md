---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK013
aliases:
  - TIK013
name: Change History Journal in Ticket Body
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 1
ticket_created: 2026-06-13T07:20:45Z
ticket_updated: 2026-06-14T05:45:20Z
ticket_completed:
---
# Introduction

Maintain a chronological history of changes to a ticket as part of the markdown body, in a `## Journal` section. Each time a frontmatter field is modified — status, priority, rank, or other metadata — append a timestamped entry documenting the change.

# Requirements

- The ticket body includes a `## Journal` section containing a chronological log of changes.
- Each entry includes an ISO 8601 timestamp and a description of the change (e.g. `- 2026-06-13T14:30:00Z — status changed from [[Backlog]] to [[In Progress]]`).
- Entries are prepended or appended in reverse chronological order (newest first).
- Changes that trigger a journal entry include: status transitions, priority changes, and rank changes.
- The `## Journal` section is created automatically on the first change if it does not yet exist.
- Existing tickets without a `## Journal` section should continue to work without errors.

# Technical Solution

In any function that modifies ticket frontmatter, after writing the change, append a journal entry to the ticket body. Detect the old and new values to construct a meaningful description. Insert the `## Journal` heading if absent.

# Execution Plan

- [ ] Implement a helper function to append journal entries to a ticket file.
- [ ] Wire journal entries into status-change, priority-change, and rank-change code paths.
- [ ] Verify status transitions produce journal entries with correct old/new values.
- [ ] Verify priority changes produce journal entries.
- [ ] Verify rank changes produce journal entries.
- [ ] Verify the `## Journal` section is created automatically on the first change.
- [ ] Verify existing tickets without a `## Journal` section do not cause errors.
