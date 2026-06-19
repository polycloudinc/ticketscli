---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK046
aliases:
  - TIK046
name: Switch From Mikefarah Yq To Python Yq
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 10
ticket_created: 2026-06-18T15:10:05Z
ticket_updated: 2026-06-18T15:10:05Z
ticket_completed:
---
# Introduction

Replace all uses of mikefarah/yq (Go) with kislyuk/yq (Python) in tickets.sh, since the Python version is the commonly available package on most systems and the Go version requires manual installation from GitHub releases.

# Requirements

- All `yq eval --front-matter extract` reads must use a Python-yq-compatible alternative for extracting front matter values from Markdown files
- All `yq eval -i --front-matter process` writes must use a Python-yq-compatible alternative for updating front matter fields in-place while preserving the Markdown body
- All `yq eval` calls on plain YAML files (settings.yaml, statistics.yaml) must use Python yq syntax
- The yq version check in `cmd_validate` must accept Python yq instead of requiring mikefarah yq
- The error messages referencing mikefarah yq must be updated

# Technical Solution

TODO

# Execution Plan

TODO