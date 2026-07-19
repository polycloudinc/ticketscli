---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK049
aliases:
- TIK049
name: Publish Npm Package To Github Packages
ticket_status: '[[In Progress]]'
ticket_priority: Medium
ticket_rank: 11
ticket_created: '2026-07-17T12:48:44Z'
ticket_updated: '2026-07-17T14:59:31Z'
---
# Introduction

In addition to publishing the NPM package to npmjs.org, store a tar.gz archive of the same package in GitHub Packages so it can be consumed from the GitHub package registry as an alternative distribution channel.

# Requirements

- A tar.gz package of the NPM package must be pushed to GitHub Packages on each publish to npmjs.org
- The package must be accessible from the GitHub Packages registry for the repository
- The package must not be published to GitHub Packages without also succeeding at npmjs.org publish
- The existing npmjs.org publish workflow must continue to function unchanged

# Technical Solution

Add a second `npm publish` step to the existing `.github/workflows/publish-npm.yaml` workflow, placed after the existing npmjs.org publish step. The new step targets the GitHub Packages npm registry (`https://npm.pkg.github.com`) and authenticates using the built-in `GITHUB_TOKEN`.

The step must:
- Run in the same working directory (`polycloud-tickets-cli/polycloud-tickets-cli-main`)
- Set `--registry https://npm.pkg.github.com` when running `npm publish`
- Authenticate via an `.npmrc` entry or `npm config set` using `secrets.GITHUB_TOKEN`
- Publish with `--access public` (same as the npmjs.org publish)
- Run sequentially after the npmjs.org publish, not in parallel

The `package.json` requires no changes — the package name (`@polycloudinc/ticketscli`) and metadata are identical across both registries.

The workflow already has `permissions: packages: write` granting `GITHUB_TOKEN` the necessary scope.

If the GitHub Packages publish fails after npmjs.org succeeds, the npmjs.org publish is not rolled back. This asymmetry is accepted as a deliberate design decision — npmjs.org is the primary registry, and a partial publish is an acceptable state.

# Execution Plan

- [x] Add `packages: write` permission to the `publish` job in `.github/workflows/publish-npm.yaml`
- [x] Add a new step after the existing npmjs.org publish that authenticates with `GITHUB_TOKEN` and runs `npm publish --registry https://npm.pkg.github.com --access public`
- [ ] Push to GitHub and verify the workflow triggers and both publishes succeed
- [ ] Verify the package is installable from GitHub Packages via `npm install @polycloudinc/ticketscli --registry https://npm.pkg.github.com`
