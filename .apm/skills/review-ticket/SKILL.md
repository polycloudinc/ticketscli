---
name: review-ticket
description: Use when the user asks to review a ticket against the current state of the codebase. Do not use for creating, ranking, kanban, or updating ticket status.
---

# Review Ticket

Read the ticket file and review it against the current state of the codebase. Identify any open questions, inconsistencies, or ambiguities.

Respond in three sections:

**Ticket Status**

The ticket code, name, and current status in the format `<ID> - <Name> - <Status>` (status as plain text, no brackets or quotes).

**Open Issues**

A numbered list of open questions, inconsistencies, or mis-alignment with the current state of the code. Each issue must include a short summary of the recommended solution and may offer multiple solution options labelled **Option A**, **Option B**, **Option C**, etc.

If no issues are identified, output:

**No issues identified.**

**Readiness**

A one-liner stating whether the ticket appears ready to be worked or not.
