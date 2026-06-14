---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK020
aliases:
  - TIK020
name: Rank Normalization Subcommand
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 7
ticket_created: 2026-06-14T03:35:08Z
---
# Introduction

Provide an on-demand rank normalization subcommand that reassigns contiguous 1..N rank integers across all tickets while preserving relative ordering and clearing ranks of done tickets.

# Requirements

- Running `tickets rank` without sub-arguments normalizes all ticket ranks on demand.
- Non-done tickets are assigned sequential ranks starting from 1, preserving their existing relative order.
- Done tickets (`[[Complete]]`, `[[Duplicate]]`, `[[Won't Fix]]`) have their rank field cleared.
- The command reports the number of tickets normalized.
- Accepts the standard `-d|--tickets-dir` flag for specifying a custom tickets directory.

# Technical Solution

TODO

# Execution Plan

TODO 