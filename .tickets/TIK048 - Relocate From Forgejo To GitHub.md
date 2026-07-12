---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK048
aliases:
  - TIK048
name: Relocate From Forgejo To GitHub
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 10
ticket_created: 2026-07-06T05:11:24Z
ticket_updated: 2026-07-06T05:11:24Z
ticket_completed:
---
# Introduction

Move the tickets CLI project and all associated infrastructure from Forgejo (forgejo.aleisium.com) to GitHub (github.com/polycloudinc/ticketscli), including the git repository, CI/CD workflows, package registry references, and all documentation. The npm package will be renamed from `@aleisium/tickets` to `@polycloudinc/ticketscli`.

# Requirements

- The git repository (full history, branches, tags) must be migrated from forgejo.aleisium.com to github.com/polycloudinc/ticketscli
- `@polycloudinc/modver` is published to npmjs.org (source: github.com/polycloudinc/modver) — this is a prerequisite, already satisfied
- Forgejo CI/CD workflows under `.forgejo/workflows/` must be converted to GitHub Actions under `.github/workflows/`:
  - `publish-npm.yml`: publish `@polycloudinc/ticketscli` to npmjs.org using GitHub Actions referencing `@polycloudinc/modver`
  - `publish-apm.yaml`: publish the APM agent skills package, tagging and pushing release tags
- The `repo-var` Forgejo-only action (used for build number increment) must be replaced with a GitHub-compatible alternative for managing build metadata
- `package.json` must be updated to reference the GitHub repository URL and switch the registry from the private Forgejo npm registry to npmjs.org; package name changes to `@polycloudinc/ticketscli`
- `apm.yml` must drop the devDependency on `als_sys_app_modver` (Forgejo-only `repo-var` action) and remove it from `apm.lock.yaml`
- Root `package-lock.json` devDependencies (`@aleisium/sourcepkg-*` from Forgejo registry) must be dropped
- `Tickets System.md` documentation must be updated to cover operating the GitHub Actions workflows, including token and permission management
- All documentation and inline references to Forgejo URLs must be updated to point to GitHub equivalents

# Technical Solution

## GitHub Actions workflows

The two Forgejo workflows (`publish.yml` and `publish-skills.yaml`) convert to `.github/workflows/` with these adjustments:

**`publish.yml`** — publishes `@polycloudinc/ticketscli` to npmjs.org:
- Trigger: push to `master` on paths `als-tickets-cli/**`, `.github/workflows/publish.yml`, `version`; plus `workflow_dispatch`
- Runs on `ubuntu-latest` with `permissions: contents: read, variables: write`
- Steps: checkout with fetch-depth 0 → setup-node@v4 (node 20) → configure npm auth token for npmjs.org → increment build number (replace `repo-var` action) → render version via modver → `npm publish`

**`publish-skills.yaml`** — publishes APM agent skills and tags releases:
- Trigger: push to `master` on paths `apm.yml`, `.apm/**`, `.github/workflows/publish-skills.yaml`, `version`; plus `workflow_dispatch`
- Runs on `ubuntu-latest` with `permissions: contents: write, variables: write` (replaces `container: node:22`)
- Steps: checkout with fetch-depth 0 → setup-node@v4 (node 22) → increment build number via `gh variable` → compute semver tag via modver → push git tag

**Replacing `repo-var`**: Use the GitHub CLI (`gh`) to read and increment a `VERSION_BUILD` repository variable. The workflow reads the current value with `gh variable list`, increments it, and writes it back with `gh variable set`. The incremented value is passed to subsequent steps via `$GITHUB_OUTPUT`. This requires `variables: write` permission on the workflow job.

**Required repository secrets**: The GitHub repository (`polycloudinc/ticketscli`) must have these secrets configured before the workflows can run:
- `NPM_TOKEN` — npmjs.org automation token for publishing `@polycloudinc/ticketscli`
- `VERSION_BUILD` — initial value (e.g., `0`) seeded as a repository variable before the first workflow run

## Registry and URL updates

- `package.json` name: `@aleisium/tickets` → `@polycloudinc/ticketscli`
- `package.json` repository URL: `ssh://git@forgejo.aleisium.com:222/aleisium/als_sys_app_tickets.git` → `https://github.com/polycloudinc/ticketscli.git`
- `package.json` `publishConfig.registry`: remove — npmjs.org is the default, no scope registry override needed
- `apm.yml`: drop `als_sys_app_modver` devDependency entirely
- `apm.lock.yaml`: remove the modver entry from dependencies; regenerate with new host
- Root `package-lock.json`: delete (no remaining devDependencies after dropping `@aleisium/sourcepkg-*`)
- Remaining Forgejo references audited and updated throughout docs and code

# Execution Plan

- [x] Verify `@polycloudinc/modver` is published and installable from npmjs.org
- [x] Create the target GitHub repository (polycloudinc/ticketscli)
- [x] Migrate git repository from forgejo.aleisium.com to GitHub with full history, branches, and tags
- [x] Update local `origin` remote to point to the new GitHub repository (polycloudinc/ticketscli)
- [ ] Create `VERSION_BUILD` repository variable on GitHub (seed with current value)
- [ ] Create `NPM_TOKEN` repository secret on GitHub
- [x] Convert `.forgejo/workflows/publish.yml` to `.github/workflows/publish.yml` using GitHub Actions syntax, `gh variable` for build number, npmjs.org auth, and `ubuntu-latest` runner
- [x] Convert `.forgejo/workflows/publish-skills.yaml` to `.github/workflows/publish-skills.yaml` using GitHub Actions syntax, `gh variable` for build number, and `ubuntu-latest` runner with `contents: write` for tag pushing
- [x] Delete `.forgejo/` directory
- [x] Update `als-tickets-cli/als-tickets-cli-main/package.json`: change name to `@polycloudinc/ticketscli`, repository URL to `https://github.com/polycloudinc/ticketscli.git`, remove `publishConfig.registry`
- [x] Drop `als_sys_app_modver` from `apm.yml` devDependencies
- [x] Remove modver entry from `apm.lock.yaml` dependencies and regenerate with new host
- [x] Delete root `package-lock.json`
- [x] Audit codebase for remaining Forgejo references and update to GitHub equivalents
- [x] Update `Tickets System.md` documentation covering GitHub Actions workflow operation, token and permission management
- [ ] Push to GitHub master branch and verify both workflows trigger correctly
- [ ] Verify `npm install @polycloudinc/ticketscli` works from npmjs.org