# tc012_api_v1_guard
#
# Verifies that commands reading or writing tickets halt when a ticket is not
# declared `api: polycloudinc/ticketscli/v1`, and that the same commands
# succeed once the ticket is migrated.

fixture() {
  echo "f002"
}

run() {
  local out

  cat > ".tickets/TST001 - Alpha Ticket.md" <<'EOF'
---
template: '[[Ticket]]'
kind: ticket
code: TST001
name: Alpha Ticket
ticket_status: '[[Backlog]]'
ticket_priority: Medium
ticket_rank: 1
ticket_created: '2026-06-01T09:00:00Z'
ticket_updated: '2026-06-01T09:00:00Z'
ticket_completed:
---
# Introduction

Unversioned ticket.
EOF

  # list halts on an unversioned ticket
  out=$("$TICKETS_CLI" list 2>&1) && { echo "list passed with unversioned ticket"; return 1; }
  grep -Fq 'TST001 - Alpha Ticket.md' <<< "$out" || { echo "list did not name the offending file: $out"; return 1; }

  # transition refuses to touch an unversioned ticket
  out=$("$TICKETS_CLI" transition -t TST001 -T ready 2>&1) && { echo "transition passed with unversioned ticket"; return 1; }
  grep -Fq 'is not declared as api' <<< "$out" || { echo "no transition guard message: $out"; return 1; }
  grep -Fq '[[Backlog]]' ".tickets/TST001 - Alpha Ticket.md" || { echo "unversioned ticket was modified"; return 1; }

  # statistics snapshot halts on an unversioned ticket
  out=$("$TICKETS_CLI" statistics snapshot 2>&1) && { echo "statistics snapshot passed"; return 1; }
  grep -Fq 'TST001 - Alpha Ticket.md' <<< "$out" || { echo "snapshot did not name the offending file: $out"; return 1; }

  # create against a directory containing an unversioned ticket halts
  out=$("$TICKETS_CLI" create -n "Second Ticket" 2>&1) && { echo "create passed with unversioned ticket present"; return 1; }
  [[ ! -f ".tickets/TST002 - Second Ticket.md" ]] || { echo "create wrote despite unversioned ticket"; return 1; }

  # After migration the same commands succeed
  "$TICKETS_CLI" migrate -t v1 >/dev/null 2>&1 || { echo "migrate failed"; return 1; }
  out=$("$TICKETS_CLI" list 2>&1) || { echo "list failed after migrate: $out"; return 1; }
  out=$("$TICKETS_CLI" transition -t TST001 -T ready 2>&1) || { echo "transition failed after migrate: $out"; return 1; }
  grep -Fq 'ticket_status: ready' ".tickets/TST001 - Alpha Ticket.md" || { echo "transition did not update v1 status"; return 1; }
  out=$("$TICKETS_CLI" statistics snapshot 2>&1) || { echo "snapshot failed after migrate: $out"; return 1; }
  grep -q '^total: 1$' <<< "$out" || { echo "snapshot count wrong: $out"; return 1; }

  echo "commands halt on unversioned tickets and recover after migration"
}