---
name: create-ticket
description: Use when the user asks to create a new ticket. Extracts a name from the user's message and uses the `tickets create` subcommand. Do not use for listing, reviewing, ranking, or updating ticket status.
---

# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides `list`, `validate`, `create`, `transition`, `rank`, and `statistics` subcommands for managing tickets.

The `tickets` CLI is published as `@aleisium/tickets`. Before running any `tickets` command, determine the correct invocation:
- If `tickets.sh` exists at the repository root, use `bash tickets.sh`.
- Otherwise, use `npx @aleisium/tickets`.

# Create Ticket

When the user asks to create a ticket:

1. Derive a concise, descriptive name for the ticket from the user's message. The name should capture the subject of the work in a few words (no trailing punctuation).

2. Format the name as title case: capitalize the first letter of every word (e.g., "add dark mode toggle" becomes "Add Dark Mode Toggle").

3. Invoke the tickets CLI with `create -n "<title-cased name>"`. The CLI auto-assigns the next ticket code, sets `ticket_status` to `[[Backlog]]`, and sets `ticket_priority` to `Medium`.

4. Verify the new ticket's front matter contains every field present in the template (`_templates/Ticket.md`). If any field is missing (e.g., `ticket_completed`), add it in the same position it appears in the template as an empty field. Do not remove any template fields, even if they have no value.

5. Edit the newly created ticket file to populate the template sections, replacing the generated TODO placeholders:

   - **Introduction**: Replace the TODO line with a 1-2 sentence explanation of the ticket's purpose, informed by the user's create prompt and relevant context from the project.

   - **Requirements**: Replace the TODO line with an itemized list of outcome-focused requirements (use `- ` bullets), derived from the user's create prompt and project context.

   - **Technical Solution**: If the user explicitly described technical decisions (architecture, libraries, approach, interfaces) in the create prompt, capture those here. Otherwise, replace the entire TODO placeholder line (the long description that starts with `TODO:`) with just the bare word `TODO`.

   - **Execution Plan**: Replace the entire TODO placeholder line (the long description that starts with `TODO:`) with just the bare word `TODO`.

6. Report the created ticket code and filename to the user.
