# tc004_list_filter_options
#
# Verifies 'tickets list' filtering: --group (backlog/active/done/todo),
# --status (exact, fuzzy substring, ambiguous, invalid), --limit, and the
# rejection of multiple filters.

fixture() {
  echo "f003"
}

run() {
  local out

  out=$("$TICKETS_CLI" list --group backlog 2>&1) || { echo "list --group backlog failed: $out"; return 1; }
  grep -q '^1 matching from 6 total tickets$' <<< "$out" || { echo "backlog group count wrong: $(tail -1 <<< "$out")"; return 1; }
  grep -q 'TST001' <<< "$out" || { echo "backlog group missing TST001"; return 1; }
  ! grep -q 'TST002' <<< "$out" || { echo "backlog group includes TST002"; return 1; }

  out=$("$TICKETS_CLI" list --group active 2>&1) || { echo "list --group active failed: $out"; return 1; }
  grep -q '^2 matching from 6 total tickets$' <<< "$out" || { echo "active group count wrong"; return 1; }
  grep -q 'TST002' <<< "$out" || { echo "active group missing TST002"; return 1; }
  grep -q 'TST003' <<< "$out" || { echo "active group missing TST003"; return 1; }

  out=$("$TICKETS_CLI" list --group done 2>&1) || { echo "list --group done failed: $out"; return 1; }
  grep -q '^3 matching from 6 total tickets$' <<< "$out" || { echo "done group count wrong"; return 1; }
  grep -q 'TST004' <<< "$out" || { echo "done group missing TST004"; return 1; }

  out=$("$TICKETS_CLI" list --group todo 2>&1) || { echo "list --group todo failed: $out"; return 1; }
  grep -q '^3 matching from 6 total tickets$' <<< "$out" || { echo "todo group count wrong"; return 1; }
  grep -q 'TST001' <<< "$out" || { echo "todo group missing TST001"; return 1; }
  ! grep -q 'TST004' <<< "$out" || { echo "todo group includes TST004"; return 1; }

  out=$("$TICKETS_CLI" list --status complete 2>&1) || { echo "list --status complete failed: $out"; return 1; }
  grep -q '^1 matching from 6 total tickets$' <<< "$out" || { echo "complete status count wrong"; return 1; }
  grep -q 'TST004' <<< "$out" || { echo "complete status missing TST004"; return 1; }

  # Fuzzy substring: 'prog' resolves to inprogress
  out=$("$TICKETS_CLI" list --status prog 2>&1) || { echo "list --status prog failed: $out"; return 1; }
  grep -q '^1 matching from 6 total tickets$' <<< "$out" || { echo "fuzzy status count wrong"; return 1; }
  grep -q 'TST003' <<< "$out" || { echo "fuzzy status missing TST003"; return 1; }

  # Ambiguous substring: 'e' matches ready, complete, and duplicate
  out=$("$TICKETS_CLI" list --status e 2>&1) && { echo "ambiguous status accepted"; return 1; }
  grep -qi 'ambiguous status' <<< "$out" || { echo "no ambiguous status error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --status zzz 2>&1) && { echo "invalid status accepted"; return 1; }
  grep -qi 'invalid status' <<< "$out" || { echo "no invalid status error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --group zzz 2>&1) && { echo "invalid group accepted"; return 1; }
  grep -qi 'invalid group' <<< "$out" || { echo "no invalid group error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --limit 2 2>&1) || { echo "list --limit 2 failed: $out"; return 1; }
  grep -q '^6 matching from 6 total tickets (limited to 2)$' <<< "$out" || { echo "limit summary wrong: $(tail -1 <<< "$out")"; return 1; }
  [[ $(grep -cE '^TST[0-9]{3}' <<< "$out") == 2 ]] || { echo "limit did not restrict displayed rows to 2"; return 1; }

  out=$("$TICKETS_CLI" list --limit 0 2>&1) && { echo "zero limit accepted"; return 1; }
  grep -q 'must be a positive integer' <<< "$out" || { echo "no positive-integer error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --group backlog --status ready 2>&1) && { echo "multiple filters accepted"; return 1; }
  grep -q 'only one filter option may be specified' <<< "$out" || { echo "no multiple-filter error: $out"; return 1; }

  echo "list filters by group and status (exact and fuzzy), limits output, and rejects invalid input"
}
