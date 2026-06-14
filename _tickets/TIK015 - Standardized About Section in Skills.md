---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK015
aliases:
  - TIK015
name: Standardized About Section in Skills
ticket_status: "[[Complete]]"
ticket_priority: Medium
ticket_rank: 
---

# Introduction

Define and enforce a standardized **About** section that every agent skill (`SKILL.md`) must include. The section provides a consistent, scannable summary of the skill's purpose, invocation scope, and what it does and does not cover.

# Requirements

- Every `SKILL.md` must include an **About** section immediately after the frontmatter and before any other content.
- The section must use the level-one heading `# About Tickets System`.
- The section content must follow a consistent structure:
  1. A short paragraph explaining the purpose and function of the ticket system. It must cover: the YAML frontmatter template, the `_tickets/` directory as the storage location, the ticket statuses and their meanings, and the presence of the `tickets` CLI. The content should give someone new to the ticket system everything they need to understand how to use it at a high level.
  2. A bullet list of **Includes** (what the skill covers).
  3. A bullet list of **Excludes** (what the skill explicitly does not cover).
- The heading and structure must be consistent across all skills: `review-ticket`, `tickets`, and any future skills.
- The canonical About content template must be tracked in a new component `als-tickets-skill-content` under the `als-tickets-skill` module.
- The component must include a script `update-about.sh` that applies the `SKILL-ABOUT.md` content (heading and opening paragraph) to every `SKILL.md` under `.apm/skills/`, replacing an existing `# About Tickets System` heading/paragraph or inserting one after the frontmatter if absent. Per-skill **Includes** and **Excludes** lists are preserved.
- Existing skills must be updated to conform to the new standard.
- Future skills created by agents or users must follow this convention.

# Technical Solution

The canonical **About** section content will be tracked in a new module `als-tickets-skill` with a component `als-tickets-skill-content` following the `module-name/component-name/` convention. Create the directory `als-tickets-skill/als-tickets-skill-content/` with a `component.yaml` identity file and a `SKILL-ABOUT.md` file containing the standardized About section template.

Define the **About** section format as follows:

```markdown
# About Tickets System

The tickets system manages work items as Markdown files in the `_tickets/` directory, each with YAML frontmatter containing fields such as `code`, `name`, `ticket_status`, `ticket_priority`, and `ticket_rank`. Tickets progress through statuses: `[[Backlog]]` (unscheduled), `[[Ready]]` (scheduled), `[[In Progress]]` (active work), `[[Complete]]` (done), `[[Duplicate]]`, and `[[Won't Fix]]`. A `tickets` CLI provides a `list` subcommand for listing tickets with filtering by status group or explicit status.

**Includes:**
- <item the skill covers>
- <item the skill covers>

**Excludes:**
- <item the skill explicitly does not cover>
- <item the skill explicitly does not cover>
```

Each existing skill's `SKILL.md` must include an **# About Tickets System** section matching this format. The opening paragraph and heading are identical across all skills; only the **Includes** and **Excludes** bullet lists are tailored to each skill's scope. The canonical template lives in `als-tickets-skill/als-tickets-skill-content/SKILL-ABOUT.md`.

## `update-about.sh` Script

The component must include a script `update-about.sh` that applies the current About section content from `SKILL-ABOUT.md` to every `SKILL.md` file under the `.apm/skills/` directory tree.

Behavior:
- Read `SKILL-ABOUT.md` from the component directory as the canonical About content (heading and introductory paragraph).
- For each `SKILL.md` under `.apm/skills/`:
  - If an `# About Tickets System` section already exists, replace the heading and opening paragraph with the canonical content, preserving any per-skill content below (such as **Includes** and **Excludes** lists).
  - If no `# About Tickets System` section exists, insert the content from `SKILL-ABOUT.md` immediately after the YAML frontmatter (after the closing `---`).
- The script must be idempotent — running it multiple times produces the same result.

Update existing skills:
- `.apm/skills/tickets/SKILL.md` — add an **# About Tickets System** section after the frontmatter, moving the introductory line into the summary and restructuring the existing content under Includes/Excludes.
- `.apm/skills/review-ticket/SKILL.md` — add an **# About Tickets System** section after the frontmatter, with Includes/Excludes matching the existing description.

The developer runs `update-about.sh` as part of the dev cycle to apply the canonical About content. Changes to `.apm/skills/` and `SKILL-ABOUT.md` are committed together so that the published package is always in sync.

## Workflow Update

Update `.forgejo/workflows/publish-skills.yaml`:
- Add `'als-tickets-skill/**'` to the `push.paths` trigger so the workflow runs when the module changes.

# Execution Plan

- [x] Create the `als-tickets-skill/als-tickets-skill-content/` module and component directory.
- [x] Create `component.yaml` identity file in the new component directory.
- [x] Create `SKILL-ABOUT.md` containing the standardized About section template.
- [x] Draft the standardized **About** section content in `SKILL-ABOUT.md`.
- [x] Create the `update-about.sh` script that reads `SKILL-ABOUT.md` and applies its heading and opening paragraph to all `SKILL.md` files under `.apm/skills/`, handling both replace (existing `# About Tickets System`) and insert (no `# About Tickets System`) while preserving per-skill Includes/Excludes lists.
- [x] Add `'als-tickets-skill/**'` to `push.paths` in `.forgejo/workflows/publish-skills.yaml`.
- [x] Run `update-about.sh` to apply the canonical About content to `.apm/skills/tickets/SKILL.md` and `.apm/skills/review-ticket/SKILL.md`.
- [x] Commit the updated `.apm/skills/` files and `SKILL-ABOUT.md` together.
- [x] Verify the script is idempotent by running it twice and confirming no diffs on the second run.
- [x] Verify both skills render correctly and the **About** section is scannable by agents.
- [x] Verify `tickets list` shows TIK015 after creating it.
