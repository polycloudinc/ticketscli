---
name: tickets-assist-commit
description: Use when the user asks for commit assistance with phrases such as "let's commit", "prepare commit", "assist commit", or "help me commit". Reviews staged and unstaged changes, relates them to the current ticket when clear, proposes a confirmed commit strategy, stages approved changes, and provides commit commands without executing commits.
---

# Assist Commit

Assist a human developer with preparing commits after a development session. The agent may inspect, unstage, and stage changes, but must never execute `git commit` for the user.

## 1. Establish Context

This skill applies to requests such as:

- `let's commit`
- `prepare commit`
- `assist commit`
- `help me commit`
- Equivalent natural-language requests for help committing

The request may follow ticket-based work or independent work.

1. Identify the ticket being worked on from the current session and conversation when it is clear.
2. If no current ticket can be clearly identified, ask the user which ticket applies. If the work is intentionally independent, continue without a ticket.
3. Inspect the complete worktree state before proposing any strategy:
   - `git status --short`
   - `git diff --cached`
   - `git diff`
4. Review both staged and unstaged changes. Do not change the index during this review.

## 2. Review Ticket Completion

When a ticket applies, read its Requirements and Execution Plan and compare them with the staged and unstaged changes.

1. Determine whether the changes represent partial work or complete the ticket scope.
2. Partial work may be committed without completing the ticket.
3. If the ticket scope appears fully complete, inspect its current `ticket_status`.
4. If the ticket is still `inprogress`, explain why it appears complete and offer the user a transition to `complete` before preparing the commit strategy.
5. Only transition the ticket after the user explicitly approves. Use the tickets CLI:

   ```bash
   npx @polycloudinc/ticketscli@latest transition -t <ticket-code> -T complete
   ```

   In this repository, `./tickets.sh transition -t <ticket-code> -T complete` is an equivalent local command when the published CLI is unavailable.
6. Complete the transition before preparing and proposing the commit strategy. Include any resulting ticket-file changes in the later strategy.

## 3. Propose A Strategy

Do not stage, unstage, or otherwise change the index until the user confirms the strategy.

Partition the changes into the smallest clear set of logical commits:

- Associate each commit with one ticket where possible.
- A single ticket may have multiple commits when that improves clarity.
- Allow ancillary commits with no ticket when the changes are independent of ticket work.
- Group newly created future-work tickets into a final commit named `Backlog grooming`.
- Include rank, timestamp, or other ticket-file changes caused by a status transition in the final `Backlog grooming` commit.
- Identify every change that should be excluded from the commits.

For one commit, state that a single commit is sufficient and list excluded changes. For multiple commits, provide a bullet list with the proposed message and a concise summary of each commit, followed by excluded changes.

Ticket-associated commit messages use this format, without a dash:

```text
<ticket code> <short summary>
```

For example: `TIK001 Change summary`. Non-ticket commit messages omit the ticket number. Do not rewrite historical commit messages.

Ask the user to confirm the strategy. If the user requests changes, revise the strategy and ask for confirmation again without changing the index.

## 4. Stage And Handoff

After the user confirms the strategy:

1. Prepare the index for the first commit. You may unstage and restage files as needed to match the approved strategy. Do not discard worktree content.
2. Verify the staged paths and diff match the first proposed commit.
3. Present the exact command for the user to run, including the prepared message:

   ```bash
   git commit -m "<prepared message>"
   ```

4. Do not run the commit command.
5. For a multi-commit strategy, wait for the user to confirm before preparing and staging the next commit. Repeat the staged-diff review and command handoff for each remaining commit.

If a commit has already been made by the user, refresh the worktree state before proceeding to the next planned commit.
