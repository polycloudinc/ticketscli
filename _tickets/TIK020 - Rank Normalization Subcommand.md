---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TIK020
aliases:
  - TIK020
name: Rank Normalization Subcommand
ticket_status: "[[Won't Fix]]"
ticket_priority: Medium
ticket_rank: 
ticket_created: 2026-06-14T03:35:08Z
ticket_updated: 2026-06-14T03:47:11Z
---
# Introduction

Provide an on-demand rank normalization subcommand that reassigns contiguous 1..N rank integers across all tickets while preserving relative ordering and clearing ranks of done tickets.

> **Won't Fix**: This ticket was already effectively complete by the original implementation. `cmd_rank()` (tickets.sh:470) and `normalize_ranks()` (tickets.sh:115) fully satisfy all requirements.

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