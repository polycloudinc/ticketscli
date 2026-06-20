---
template: '[[Ticket]]'
kind: ticket
tags:
- ticket
code: TIK029
aliases:
- TIK029
name: Publish Project As Open Source
ticket_status: '[[Ready]]'
ticket_priority: Medium
ticket_rank: 1
ticket_created: '2026-06-14T07:19:17Z'
ticket_updated: '2026-06-16T02:29:58Z'
---
# Introduction

Prepare and publish the Markdown Tickets System as an open source project, making the CLI, agent skills, and supporting tooling publicly available under an appropriate license with clear documentation for community adoption and contribution.

# Requirements

- The project has a clear open source license (LICENSE file in repository root).
- A README.md exists with installation instructions, usage examples, and an overview of the system.
- A CONTRIBUTING.md guide is available for external contributors.
- All internal-only or organization-specific references are reviewed and either removed, generalized, or documented as optional.
- The repository is published to a publicly accessible hosting service (GitHub or public Forgejo instance).
- Existing CI/CD workflows continue to function correctly in the public context.
- No secrets, credentials, or internal infrastructure details are present in the public repository.
- The npm package `@aleisium/tickets` is published to the public npm registry or an alternative public package registry.
- The agent skills remain functional for any user who clones the repository.
- A CODE_OF_CONDUCT.md (or similar community health file) is included.

# Technical Solution

TODO

# Execution Plan

TODO 