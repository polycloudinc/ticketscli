---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK071
ticket_name: Add Review Walkthrough Follow-Up Choices
ticket_status: backlog
ticket_priority: Medium
ticket_rank: 24
ticket_created: 2026-10-16T02:26:43Z
ticket_updated: 2026-10-16T03:30:49Z
ticket_completed:
---
# Introduction

Give users more context and decision support while stepping through ticket-review findings. After they choose how to resolve each issue, let them apply those decisions to the reviewed ticket or discard them.

# Requirements

- For each issue in the optional review walkthrough, users can request more background or a recommendation in addition to choosing a resolution or entering a custom alternative.
- Background elaboration provides relevant issue context without inventing facts.
- A recommendation compares the available resolutions and explains the recommendation's pros, cons, and rationale.
- After either informational follow-up, the choices for the same issue are presented again so the user can select a resolution.
- After all issues have been discussed, the skill summarizes the user's decisions and then offers selectable choices to apply the decisions to the reviewed ticket or discard them.
- The ticket is modified only if the user explicitly chooses to apply the decisions. Applying them updates only the relevant content in the reviewed ticket; unrelated ticket content and code files are not modified.
- Choosing to discard leaves the reviewed ticket and code files unchanged.
- Project documentation describes the issue follow-ups and the final apply-or-discard choice.

# Technical Solution

Update the canonical `.apm/skills/tickets-review/SKILL.md` instructions to add two selectable follow-ups for each issue: `Elaborate on the background` and `Make a recommendation, including pros, cons, and reasons for the recommendation`. The former should explain relevant context; the latter should compare the available resolutions, state a recommendation, and justify it. Both follow-ups return to the same issue's choices without advancing the walkthrough. After collecting a resolution or custom alternative for every issue, summarize the decisions and then offer `Apply decisions to the ticket` and `Discard decisions` as selectable choices. Apply only after the user chooses to apply; update only relevant content in the reviewed ticket, preserve unrelated content, and report the edits. Discard makes no changes. Keep the report and walkthrough read-only until this final choice, and never modify code files. Synchronize the generated skill through APM and document the complete behavior in `Tickets System.md`.

# Execution Plan

## Phase 1: Issue Follow-Up Choices

### Tasks

- [x] Add selectable background elaboration and recommendation follow-ups to each issue walkthrough prompt.
- [x] Define the background response and recommendation content, and repeat the same issue's choices after either follow-up.
- [x] Keep the report and issue walkthrough read-only while allowing users to select a resolution or enter a custom alternative after the follow-ups.
- [x] Synchronize the canonical review skill to the generated `.agents/skills/` deployment through APM.
- [x] Document the new choices and walkthrough behavior in `Tickets System.md`.

### Agent Verifications

- [x] VA01: Run `apm audit --ci`; expected result: all checks pass with no lockfile drift.
- [x] VA02: Compare `.apm/skills/tickets-review/SKILL.md` with `.agents/skills/tickets-review/SKILL.md` and run `git diff --check`; expected result: the deployed skill matches its source and there are no whitespace errors.

### Human Verification Steps

#### VH01: Exercise Walkthrough Follow-Ups

Status: Pending

Prerequisites and working directory: An agent client with the updated `tickets-review` skill installed; any working directory in the project.

Instructions:
1. Choose a ticket with at least one known open review issue and ask the agent to review it.
2. Agree to the one-by-one walkthrough. For an issue, select **Elaborate on the background** and confirm that the agent explains the context and presents the same issue's choices again.
3. Select **Make a recommendation, including pros, cons, and reasons for the recommendation** and confirm that the agent compares resolutions, explains its recommendation, and presents the same issue's choices again.
4. Select a resolution or enter a custom alternative. Confirm the walkthrough proceeds to the next issue (if any), then recaps choices without modifying files.

Prompts to send:

```text
Review a ticket with at least one known open issue and step through the issues one-by-one. For the first issue, elaborate on the background, then make a recommendation with pros, cons, and reasons. After each explanation, show me the choices for that same issue again.
```

Expected result: Both follow-ups provide the requested information and return to the current issue's choices; a selected resolution advances the walkthrough, and no files are changed.

## Phase 2: Apply or Discard Walkthrough Decisions

### Tasks

- [x] After the issue walkthrough is complete, summarize the user's decisions before asking whether to apply or discard them.
- [x] Offer selectable `Apply decisions to the ticket` and `Discard decisions` choices after the summary.
- [x] On explicit apply, update only the relevant content in the reviewed ticket based on the user's resolutions or alternatives, preserve unrelated content, and report the changes.
- [x] On discard, leave the reviewed ticket and all code files unchanged.
- [x] Synchronize the updated review skill through APM and document the final apply-or-discard behavior in `Tickets System.md`.

### Agent Verifications

- [x] VA03: Run `apm audit --ci` after synchronizing; expected result: all checks pass and the generated skill has no lockfile drift.
- [x] VA04: Run `bash polycloud-tickets-cli/polycloud-tickets-cli-main/tickets.sh validate --ticket TIK071` and `git diff --check`; expected result: the ticket validates and no whitespace errors are reported.

### Human Verification Steps

#### VH02: Apply or Discard Review Decisions

Status: Pending

Prerequisites and working directory: An agent client with the updated `tickets-review` skill installed and a ticket with known open issues; work in the project directory.

Instructions:
1. Review the chosen ticket, accept the one-by-one walkthrough, and select a resolution or custom alternative for each issue.
2. Confirm the agent summarizes the collected decisions, then offers the apply and discard choices.
3. In one run, choose **Discard decisions** and confirm the reviewed ticket remains unchanged.
4. In a separate run using a disposable or safely revertible ticket, choose **Apply decisions to the ticket** and confirm only relevant ticket content changes to reflect the selections; verify no unrelated ticket content or code files changed.

Prompts to send:

```text
Review a ticket with known open issues and step through them one-by-one. After I answer each issue, summarize my decisions and offer me the choice to apply them to the ticket or discard them.
```

Expected result: The final apply/discard prompt appears only after the decision summary. Discard makes no file changes; apply updates only relevant content in the reviewed ticket and reports the changes.
