# tc011_migrate_unversioned_to_v1
#
# Verifies 'tickets migrate -t v1': unversioned tickets are converted (api
# first key, Obsidian fields dropped, keys renamed, statuses remapped, data
# preserved), re-running skips already-migrated tickets, and unknown targets
# or unknown api versions are rejected.

fixture() {
  echo "f002"
}

run() {
  local out

  cat > ".tickets/TST001 - Alpha Ticket.md" <<'EOF'
---
template: "[[Ticket]]"
kind: ticket
tags:
  - ticket
code: TST001
aliases:
  - TST001
name: Alpha Ticket
ticket_status: "[[Backlog]]"
ticket_priority: Medium
ticket_rank: 1
ticket_created: 2026-06-01T09:00:00Z
ticket_updated: 2026-06-01T09:00:00Z
ticket_completed:
---
# Introduction

Unversioned ticket.
EOF

  cat > ".tickets/TST002 - Bravo Ticket.md" <<'EOF'
---
template: "[[Ticket]]"
kind: ticket
tags:
- ticket
code: TST002
aliases:
- TST002
name: Bravo Ticket
ticket_status: "[[Won't Fix]]"
ticket_priority: Low
ticket_rank: null
ticket_created: "2026-06-02T10:00:00Z"
ticket_updated: "2026-06-03T11:00:00Z"
ticket_completed: "2026-06-03T11:00:00Z"
---
# Introduction

Unversioned done ticket.
EOF

  out=$("$TICKETS_CLI" migrate -t v1 2>&1) || { echo "migrate failed: $out"; return 1; }
  grep -q '2 ticket(s) migrated to v1, 0 skipped, 0 failed' <<< "$out" || { echo "bad migrate summary: $out"; return 1; }

  local f1=".tickets/TST001 - Alpha Ticket.md"
  local f2=".tickets/TST002 - Bravo Ticket.md"

  awk '/^---$/{c++; next} c==1{print; exit}' "$f1" | grep -q '^api: polycloudinc/ticketscli/v1$' || { echo "api not the first key"; return 1; }
  grep -q '^template:' "$f1" && { echo "template key not dropped"; return 1; }
  grep -q '^tags:' "$f1" && { echo "tags key not dropped"; return 1; }
  grep -q '^aliases:' "$f1" && { echo "aliases key not dropped"; return 1; }
  grep -q '^kind: ticket$' "$f1" || { echo "kind key not retained"; return 1; }
  grep -q '^ticket_code: TST001$' "$f1" || { echo "code not renamed to ticket_code"; return 1; }
  grep -q '^ticket_name: Alpha Ticket$' "$f1" || { echo "name not renamed to ticket_name"; return 1; }
  grep -q '^ticket_status: backlog$' "$f1" || { echo "status not remapped to backlog"; return 1; }
  grep -q '^ticket_priority: Medium$' "$f1" || { echo "priority not preserved"; return 1; }
  grep -q '^ticket_rank: 1$' "$f1" || { echo "rank not preserved"; return 1; }
  grep -q '^ticket_created: "2026-06-01T09:00:00Z"$' "$f1" || { echo "created timestamp corrupted"; return 1; }

  grep -q '^ticket_status: wontfix$' "$f2" || { echo "done status not remapped to wontfix"; return 1; }
  grep -q '^ticket_completed: "2026-06-03T11:00:00Z"$' "$f2" || { echo "completed timestamp corrupted"; return 1; }
  grep -Eq '^ticket_rank:$' "$f2" || { echo "done rank not preserved"; return 1; }

  # Idempotent: already-migrated tickets are skipped
  out=$("$TICKETS_CLI" migrate -t v1 2>&1) || { echo "second migrate failed: $out"; return 1; }
  grep -q '0 ticket(s) migrated to v1, 2 skipped, 0 failed' <<< "$out" || { echo "skip summary wrong: $out"; return 1; }

  # Unknown target version is rejected
  out=$("$TICKETS_CLI" migrate -t v2 2>&1) && { echo "unsupported target accepted"; return 1; }
  grep -q "unsupported target version 'v2'" <<< "$out" || { echo "no unsupported-target error: $out"; return 1; }

  # A ticket declaring an unknown api version is reported and left untouched
  cat > ".tickets/TST003 - Charlie Ticket.md" <<'EOF'
---
api: polycloudinc/ticketscli/v0
kind: ticket
ticket_code: TST003
ticket_name: Charlie Ticket
ticket_status: ready
ticket_priority: Medium
ticket_rank: 3
ticket_created: 2026-06-04T08:00:00Z
ticket_updated: 2026-06-04T08:00:00Z
ticket_completed:
---
# Introduction

Foreign-version ticket.
EOF
  out=$("$TICKETS_CLI" migrate -t v1 2>&1) || { echo "migrate with foreign api failed: $out"; return 1; }
  grep -qF 'declares api' <<< "$out" || { echo "no unknown-api error: $out"; return 1; }
  grep -q '^api: polycloudinc/ticketscli/v0$' ".tickets/TST003 - Charlie Ticket.md" || { echo "foreign ticket was modified"; return 1; }

  echo "migrate converts unversioned tickets to v1, skips migrated tickets, and rejects bad targets/versions"
}