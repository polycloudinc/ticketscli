# tc002_create_assigns_defaults
#
# Verifies that 'tickets create' assigns the next sequential code, default
# status/priority, the next rank, and ISO 8601 UTC timestamps.

fixture() {
  echo "f002"
}

run() {
  local out
  out=$("$TICKETS_CLI" create -n "My First Ticket" 2>&1) || { echo "create failed: $out"; return 1; }

  local f=".tickets/TST001 - My First Ticket.md"
  [[ -f "$f" ]] || { echo "ticket file not created: $f"; return 1; }
  grep -q '^api: polycloudinc/ticketscli/v1$' "$f" || { echo "api key missing or not first"; return 1; }
  grep -q '^ticket_code: TST001$' "$f" || { echo "ticket_code is not TST001"; return 1; }
  grep -q '^ticket_status: backlog$' "$f" || { echo "status is not backlog"; return 1; }
  grep -q '^ticket_priority: Medium$' "$f" || { echo "priority is not Medium"; return 1; }
  grep -q '^ticket_rank: 1$' "$f" || { echo "rank is not 1"; return 1; }
  grep -Eq '^ticket_created: [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' "$f" || { echo "ticket_created is not ISO 8601 UTC"; return 1; }
  grep -Eq '^ticket_updated: [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' "$f" || { echo "ticket_updated is not ISO 8601 UTC"; return 1; }
  grep -q '^ticket_completed:$' "$f" || { echo "ticket_completed is not empty"; return 1; }

  out=$("$TICKETS_CLI" create -n "Second Ticket" 2>&1) || { echo "second create failed: $out"; return 1; }
  local f2=".tickets/TST002 - Second Ticket.md"
  grep -q '^ticket_code: TST002$' "$f2" || { echo "second ticket_code is not TST002"; return 1; }
  grep -q '^ticket_rank: 2$' "$f2" || { echo "second rank is not 2"; return 1; }

  echo "create assigns sequential codes, backlog/Medium defaults, ranks 1 and 2, and ISO timestamps"
}
