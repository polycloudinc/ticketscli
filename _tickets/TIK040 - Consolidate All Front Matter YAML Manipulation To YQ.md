---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK040
aliases:
  - TIK040
name: Consolidate All Front Matter YAML Manipulation To YQ
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 9
ticket_created: 2026-06-14T15:04:35Z
ticket_updated: 2026-06-14T15:04:35Z
ticket_completed:
---
# Introduction

Standardize all front matter YAML reading and manipulation in tickets.sh to use mikefarah/yq instead of ad-hoc sed/grep pipelines, ensuring consistent and robust YAML handling across all subcommands.

# Requirements

- All front matter field reads must use `yq eval --front-matter extract` instead of `sed -n '/^---$/,/^---$/p' | grep | sed` pipelines
- All front matter field writes must use `yq eval -i` instead of `sed -i` in-place edits
- `get_ticket_rank` helper must use yq
- `set_ticket_rank` helper must use yq
- `normalize_ranks` must use yq for reading status and rank
- `cmd_list` must use yq for reading name, status, and rank fields
- `cmd_create` must use yq for reading existing ranks
- `cmd_transition` must use yq for reading and writing ticket_status, ticket_rank, ticket_completed, and ticket_updated
- `touch_ticket_updated` must use yq for deleting and inserting ticket_updated
- `settings.yaml` reads must use yq consistently (`cmd_create` currently uses sed, `cmd_validate` uses yq)

# Technical Solution

TODO

# Execution Plan

TODO 