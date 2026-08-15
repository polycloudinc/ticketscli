# tc006_transition_lifecycle
#
# Verifies 'tickets transition' across the lifecycle: status updates,
# ticket_completed set and rank cleared on completion, normalization of
# remaining ranks, ticket_completed removed and rank appended on reopening,
# ticket_updated touched, and fuzzy/ambiguous/invalid target handling.

fixture() {
  echo "f003"
}

run() {
  local f=".tickets/TST001 - Alpha Ticket.md"
  local out before_updated

  before_updated=$(grep '^ticket_updated:' "$f")

  out=$("$TICKETS_CLI" transition -t TST001 -T ready 2>&1) || { echo "transition to ready failed: $out"; return 1; }
  grep -F 'ticket_status:' "$f" | grep -Fq '[[Ready]]' || { echo "status is not [[Ready]]"; return 1; }
  grep -q '^ticket_rank: 2$' "$f" || { echo "rank changed on ready transition"; return 1; }
  [[ "$(grep '^ticket_updated:' "$f")" != "$before_updated" ]] || { echo "ticket_updated not touched"; return 1; }

  out=$("$TICKETS_CLI" transition -t TST001 -T inprogress 2>&1) || { echo "transition to inprogress failed: $out"; return 1; }
  grep -F 'ticket_status:' "$f" | grep -Fq '[[In Progress]]' || { echo "status is not [[In Progress]]"; return 1; }

  # Fuzzy target: 'comp' resolves to complete
  out=$("$TICKETS_CLI" transition -t TST001 -T comp 2>&1) || { echo "fuzzy complete transition failed: $out"; return 1; }
  grep -F 'ticket_status:' "$f" | grep -Fq '[[Complete]]' || { echo "status is not [[Complete]]"; return 1; }
  grep -Eq '^ticket_rank:( null)?$' "$f" || { echo "rank not cleared on completion"; return 1; }
  grep -Eq "^ticket_completed: '?[0-9]{4}-[0-9]{2}-" "$f" || { echo "ticket_completed not set"; return 1; }

  # Remaining active ranks normalized: TST002 stays 1, TST003 becomes 2
  grep -q '^ticket_rank: 1$' ".tickets/TST002 - Bravo Ticket.md" || { echo "TST002 rank not 1 after normalization"; return 1; }
  grep -q '^ticket_rank: 2$' ".tickets/TST003 - Charlie Ticket.md" || { echo "TST003 rank not normalized to 2"; return 1; }

  # Reopen to backlog: ticket_completed removed, rank appended at the end
  out=$("$TICKETS_CLI" transition -t TST001 -T backlog 2>&1) || { echo "reopen transition failed: $out"; return 1; }
  grep -F 'ticket_status:' "$f" | grep -Fq '[[Backlog]]' || { echo "status is not [[Backlog]] after reopen"; return 1; }
  ! grep -q '^ticket_completed:' "$f" || { echo "ticket_completed not removed on reopen"; return 1; }
  grep -q '^ticket_rank: 3$' "$f" || { echo "rank not appended at the end on reopen"; return 1; }

  # Ambiguous target: 'd' matches ready and duplicate
  out=$("$TICKETS_CLI" transition -t TST002 -T d 2>&1) && { echo "ambiguous target accepted"; return 1; }
  grep -qi 'ambiguous status' <<< "$out" || { echo "no ambiguous status error: $out"; return 1; }

  # Invalid target
  out=$("$TICKETS_CLI" transition -t TST002 -T zzz 2>&1) && { echo "invalid target accepted"; return 1; }
  grep -qi 'invalid status' <<< "$out" || { echo "no invalid status error: $out"; return 1; }

  echo "transition lifecycle updates status, clears/restores rank and completed timestamps, and rejects ambiguous targets"
}