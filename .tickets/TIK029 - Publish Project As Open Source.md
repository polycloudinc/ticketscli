---
api: polycloudinc/ticketscli/v1
kind: ticket
ticket_code: TIK029
ticket_name: Publish Project As Open Source
ticket_status: complete
ticket_priority: Medium
ticket_rank:
ticket_created: "2026-06-14T07:19:17Z"
ticket_updated: "2026-08-15T08:32:05Z"
ticket_completed: "2026-08-15T08:31:59Z"
---
# Introduction

Prepare and publish the Markdown Tickets System as an open source project, making the CLI, agent skills, and supporting tooling publicly available under an appropriate license with clear documentation for community adoption and contribution.

# Requirements

- The project has a clear open source license (LICENSE file in repository root).
- A README.md exists that simply links to `Tickets System.md`.
- A CONTRIBUTING.md guide is available for external contributors.
- All internal-only or organization-specific references are reviewed and either removed, generalized, or documented as optional.
- The repository is published to a publicly accessible hosting service (GitHub or public Forgejo instance).
- Existing CI/CD workflows continue to function correctly in the public context.
- No secrets, credentials, or internal infrastructure details are present in the public repository.
- The npm package `@polycloudinc/ticketscli` is published to the public npm registry or an alternative public package registry.
- The agent skills remain functional for any user who clones the repository.
- A CODE_OF_CONDUCT.md (or similar community health file) is included.

# Technical Solution

TODO

# Execution Plan

## Community Documentation

### Tasks
- [x] Author root `README.md` that simply links to `Tickets System.md`
- [x] Author `CONTRIBUTING.md` covering development setup (devcontainer), the ticket-driven workflow, and commit conventions (`gitct.sh`)

### Verification Steps
- [x] Verify the docs exist and the README links through: `test -f README.md && test -f CONTRIBUTING.md && grep -q "Tickets System.md" README.md`

## Internal Reference Cleanup

### Tasks
- [x] Remove the `@aleisium/sourcepkg-*` devDependencies from root `package.json`
- [x] Delete root `package-lock.json` (contains private Forgejo registry URLs and the legacy `mv_pdg_tickets` package name)
- [x] Keep both remotes configured for dual hosting (Forgejo `origin` and GitHub `github`) and verify master is pushed to both — do not retire the Forgejo remote
- [x] Add `tests/test_no_internal_refs.sh` smoke test asserting no `aleisium` or `forgejo.aleisium.com` references remain outside `.tickets/` historical records

### Verification Steps
- [x] Run `tests/test_no_internal_refs.sh`

## Devcontainer Repair

### Tasks
- [x] Fix the missing comma in the `mounts` array of `.devcontainer/devcontainer.json`

### Verification Steps
- [x] Validate the file parses as JSON: `python3 -c "import json; json.load(open('.devcontainer/devcontainer.json'))"`

## Package Registry Verification

### Tasks
- [x] Update this ticket's npm requirement text from `@aleisium/tickets` to `@polycloudinc/ticketscli`

### Verification Steps
- [x] Run `npm view @polycloudinc/ticketscli version` and confirm it resolves from npmjs.org (executed via curl equivalent against registry.npmjs.org — npm unavailable in the execution environment; resolved 1.0.96)
- [x] Run `npx @polycloudinc/ticketscli@latest list` from a scratch directory and confirm the CLI executes (executed via tarball-download equivalent from npmjs.org — npx unavailable in the execution environment; CLI listed tickets successfully)
