---
name: tickets-assist-commit
description: Use when the user asks to commit, including a standalone "commit" prompt, or asks for commit assistance with phrases such as "let's commit", "prepare commit", "assist commit", or "help me commit". Reviews staged and unstaged changes, relates them to the current ticket when clear, proposes a confirmed commit strategy, stages approved changes, then offers to execute each commit or provide its command.
---

# Assist Commit

Assist a human developer with preparing commits after a development session. The agent may inspect, unstage, and stage changes. It may execute a commit only after the user selects the explicit **Yes, execute the commit** choice for that verified commit; otherwise, provide the command for the user to run.

## 1. Establish Context

This skill applies to requests such as:

- `commit`
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
6. Complete the transition before preparing and proposing the commit strategy.
7. After a transition or rank operation, refresh `git status --short`, `git diff --cached`, and `git diff`. Inspect every changed `.tickets/*.md` file, not only the current ticket, for collateral rank, timestamp, completion-field, or YAML-serialization updates caused by the CLI. Do not classify metadata-only ticket changes as unrelated until their cause has been checked. Keep the current work ticket's own file with its ticket-associated commit; include collateral metadata changes to other tickets in the final `Backlog grooming` commit.

## 3. Propose A Strategy

Do not stage, unstage, or otherwise change the index until the user confirms the strategy.

Partition the changes into the smallest clear set of logical commits:

- Associate each commit with one ticket where possible.
- A single ticket may have multiple commits when that improves clarity.
- Allow ancillary commits with no ticket when the changes are independent of ticket work.
- Keep the current work ticket's file, including its own status transition, with that ticket's implementation commit.
- Group newly created future-work tickets and collateral rank, timestamp, completion-field, or YAML-serialization changes to other ticket files caused by status transitions or rank normalization into a final commit named `Backlog grooming`.
- Do not create a `Backlog grooming` commit when there are no such ticket changes.
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
3. Present the prepared commit message first in its own fenced `text` block:

   ```text
   <prepared message>
   ```

4. Present the exact, copy-pasteable commit command in its own fenced `bash` block:

   ```bash
   git commit -m "<prepared message>"
   ```

5. After both blocks are shown, ask the user with a selectable question: **Would you like me to execute the commit?** Use exactly these choices:

   - **Yes, execute the commit** — execute the displayed command for the verified staged diff.
   - **No, I will do it myself** — do not execute the command; leave the displayed command for the user to run.

   Never execute a commit unless the user selects **Yes, execute the commit** for the currently verified staged diff and message.

6. For a multi-commit strategy, wait until the user-run or agent-run commit is confirmed complete before preparing and staging the next commit. Repeat the staged-diff review, message block, command block, and selectable execution choice for each remaining commit.

If a commit has already been made by the user, refresh the worktree state before proceeding to the next planned commit.
