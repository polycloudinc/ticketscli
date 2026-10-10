---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK067
ticket_name: Assist Commit Skill
ticket_status: complete
ticket_priority: Medium
ticket_rank:
ticket_created: '2026-10-10T01:54:48Z'
ticket_updated: '2026-10-10T02:48:01Z'
ticket_completed: '2026-10-10T02:47:51Z'
---
# Introduction

Create a new agent skill that acts as a copilot for a human developer preparing commits after a development session. The skill should be named Assist Commit, respond to natural commit-assistance requests, review the worktree, relate changes to the active ticket when one exists, and guide the developer through a confirmed commit strategy without making commits on the developer's behalf.

# Requirements

- The skill is triggered by commit-assistance phrases such as `let's commit`, `prepare commit`, `assist commit`, and `help me commit`, including equivalent natural wording
- The skill can be triggered after a change-making session, whether or not the work was based on a ticket
- The agent reviews both staged and unstaged changes and compares them with the active ticket when one exists
- The agent uses the ticket being worked on in the current session when it is clearly identified, and asks the user to identify the ticket when it is not clear
- Before proposing a commit strategy, the agent reviews the changes against the active ticket's scope and execution plan to assess whether the ticket is fully complete
- The workflow supports committing an incomplete ticket as well as committing changes that complete the full ticket scope
- When the ticket scope is fully complete, the agent checks the ticket status
- If a fully completed ticket is still `inprogress`, the agent offers and recommends transitioning it to `complete` before preparing commits
- The agent obtains the user's approval for the proposed transition and uses the tickets CLI to perform it before preparing and proposing the commit strategy
- Before changing staged files, the agent proposes a commit strategy and confirms it with the user
- The strategy supports either one commit or multiple logical commits, and identifies changes to exclude
- The user can request changes to the proposed strategy and the agent revises it before staging anything
- For a single commit, the agent states that one commit is sufficient and identifies excluded changes
- For multiple commits, the agent presents a bullet list summarizing each proposed commit and identifies excluded changes
- After strategy confirmation, the agent stages one commit's changes at a time and provides the prepared `git commit` command and message for the user's final review
- When multiple commits are planned, the agent waits for user confirmation before staging changes for the next commit
- Each commit is associated with one ticket where possible, and a single ticket may have multiple commits
- Ancillary commits unrelated to any ticket are allowed when appropriate
- Where a commit is associated with a ticket, its message includes the ticket number followed by a short summary without a dash, such as `TIK001 Change summary`
- For changes unrelated to any ticket, the ticket number may be omitted from the commit message
- Unrelated, non-ticket changes may be split into multiple logical commits when appropriate
- When new tickets capture future work discovered during the active ticket, those ticket files are grouped into a final commit named `Backlog grooming`
- Ticket status transitions that modify other ticket files, such as rank or timestamp changes, are included in the final `Backlog grooming` commit
- The agent may unstage and restage changes as needed to implement the user-approved commit strategy
- The agent does not execute the commit command for the user

# Technical Solution

The skill should be named Assist Commit and define trigger examples including `let's commit`, `prepare commit`, `assist commit`, and `help me commit`, while accepting equivalent natural wording. Before developing a commit strategy, it should compare staged and unstaged changes with the active ticket's requirements and execution plan, if any, and determine whether the scope is complete or partial. It should use the ticket being worked on in the current session when clear and ask the user when no current ticket can be clearly identified. It should allow the user to commit partial work without requiring ticket completion. When the scope is complete, it should inspect the ticket status and, if the status is still `inprogress`, recommend and offer a transition to `complete`. The user must approve that transition; after approval, the agent must use the tickets CLI to perform it before preparing and proposing the commit strategy. The workflow has two stages: first, produce and revise a commit strategy without changing the index; second, after confirmation, unstage and restage files as needed for each planned commit and present its commit command and message without running it. Each subsequent commit in a multi-commit strategy requires user confirmation before additional staging changes. Each commit should contain changes for one ticket where possible, but a ticket may be represented by multiple commits and ancillary commits may have no ticket. Ticket-aware commit messages should follow `<ticket code> <short summary>` without a dash; historical commit messages are not changed. If new ticket files or ticket metadata changes result from backlog grooming or a status transition, the strategy should reserve a final `Backlog grooming` commit for those files.

# Execution Plan

## Phase 1: Trigger And Session Context

### Tasks

- [x] Define the Assist Commit skill trigger for phrases such as `let's commit`, `prepare commit`, `assist commit`, and `help me commit`
- [x] Identify the current ticket from the session context or ask the user when no ticket is clearly identified

### Verification Steps

- [x] Verify the skill description matches the supported trigger phrases and handles both ticket-based and independent sessions

## Phase 2: Change And Ticket Review

### Tasks

- [x] Review staged and unstaged changes against the applicable ticket requirements and execution plan
- [x] Assess whether the ticket scope is partial or fully complete before proposing commits
- [x] Support partial-ticket commits without requiring ticket completion
- [x] When a fully complete ticket is `inprogress`, obtain user approval and use the tickets CLI to transition it to `complete` before preparing and proposing the commit strategy

### Verification Steps

- [x] Verify representative partial and complete ticket sessions produce the correct completion assessment and transition recommendation

## Phase 3: Commit Strategy

### Tasks

- [x] Propose either one commit or multiple logical commits and identify excluded changes
- [x] Associate each commit with one ticket where possible while allowing multiple commits for one ticket and ancillary commits without tickets
- [x] Define ticket-aware commit messages as `<ticket code> <short summary>` without a dash and preserve historical message formats
- [x] Reserve a final `Backlog grooming` commit for newly created future-work tickets and ticket metadata changes caused by transitions
- [x] Update contributor documentation and commit helper guidance for the new multi-commit and no-dash message conventions
- [x] Obtain user confirmation and support revisions before changing the index

### Verification Steps

- [x] Verify sample strategies correctly group ticket, ancillary, and backlog-grooming changes and use the required message formats

## Phase 4: Staging And Commit Handoff

### Tasks

- [x] Unstage and restage files as needed to implement the approved strategy
- [x] Stage one planned commit at a time and provide the corresponding `git commit` command without executing it
- [x] Require user confirmation before staging the next commit in a multi-commit strategy

### Verification Steps

- [x] Verify the staged file set for each sample commit matches the approved strategy and that the agent never runs the commit command
