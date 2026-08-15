# tc005_validate_schema
#
# Verifies 'tickets validate': pristine fixture tickets pass, and tampered
# front matter (invalid status, unknown field, missing field, invalid rank,
# invalid timestamp) is reported with a non-zero exit.

fixture() {
  echo "f003"
}

run() {
  local out f=".tickets/TST001 - Alpha Ticket.md"

  out=$("$TICKETS_CLI" validate --all 2>&1) || { echo "validate --all failed on pristine fixture: $out"; return 1; }
  grep -q '6 ticket(s) validated, no deviations found.' <<< "$out" || { echo "unexpected validate summary: $out"; return 1; }

  out=$("$TICKETS_CLI" validate --ticket TST001 2>&1) || { echo "validate --ticket TST001 failed on pristine ticket: $out"; return 1; }

  # Invalid status value
  sed -i 's/^ticket_status:.*$/ticket_status: "[[Bogus]]"/' "$f"
  out=$("$TICKETS_CLI" validate --ticket TST001 2>&1) && { echo "validate passed with bogus status"; return 1; }
  grep -q 'Invalid value for ticket_status' <<< "$out" || { echo "missing ticket_status error: $out"; return 1; }
  sed -i 's/^ticket_status:.*$/ticket_status: "[[Backlog]]"/' "$f"

  # Unknown field
  sed -i '/^ticket_priority:/i bogus_field: surprise' "$f"
  out=$("$TICKETS_CLI" validate --ticket TST001 2>&1) && { echo "validate passed with unknown field"; return 1; }
  grep -q 'Unknown field: bogus_field' <<< "$out" || { echo "missing unknown-field error: $out"; return 1; }
  sed -i '/^bogus_field:/d' "$f"

  # Missing required field
  sed -i '/^ticket_priority:/d' "$f"
  out=$("$TICKETS_CLI" validate --ticket TST001 2>&1) && { echo "validate passed with missing field"; return 1; }
  grep -q 'Missing required field: ticket_priority' <<< "$out" || { echo "missing required-field error: $out"; return 1; }
  sed -i '/^ticket_status:/a ticket_priority: Medium' "$f"

  # Invalid (non-integer) rank on an active ticket
  sed -i 's/^ticket_rank:.*$/ticket_rank: abc/' "$f"
  out=$("$TICKETS_CLI" validate --ticket TST001 2>&1) && { echo "validate passed with non-integer rank"; return 1; }
  grep -q 'Invalid value for ticket_rank' <<< "$out" || { echo "missing ticket_rank error: $out"; return 1; }
  sed -i 's/^ticket_rank:.*$/ticket_rank: 2/' "$f"

  # Invalid created timestamp
  sed -i 's/^ticket_created:.*$/ticket_created: yesterday/' "$f"
  out=$("$TICKETS_CLI" validate --ticket TST001 2>&1) && { echo "validate passed with bad timestamp"; return 1; }
  grep -q 'Invalid value for ticket_created' <<< "$out" || { echo "missing ticket_created error: $out"; return 1; }
  sed -i 's/^ticket_created:.*$/ticket_created: 2026-06-01T09:00:00Z/' "$f"

  # Ticket restored to pristine state
  out=$("$TICKETS_CLI" validate --all 2>&1) || { echo "fixture not restored cleanly: $out"; return 1; }

  echo "validate passes pristine tickets and reports invalid status, unknown/missing fields, bad rank, and bad timestamps"
}
