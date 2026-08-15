# tc008_statistics_snapshot
#
# Verifies 'tickets statistics snapshot' counts per status, group totals,
# persistence to statistics.yaml, and that successive snapshots append.

fixture() {
  echo "f003"
}

run() {
  local out s=".tickets/statistics.yaml"

  out=$("$TICKETS_CLI" statistics snapshot 2>&1) || { echo "snapshot failed: $out"; return 1; }
  grep -q '^total: 6$' <<< "$out" || { echo "total count wrong: $out"; return 1; }
  grep -q '^  backlog: 1$' <<< "$out" || { echo "backlog count wrong: $out"; return 1; }
  grep -q '^  ready: 1$' <<< "$out" || { echo "ready count wrong"; return 1; }
  grep -q '^  inprogress: 1$' <<< "$out" || { echo "inprogress count wrong"; return 1; }
  grep -q '^  complete: 1$' <<< "$out" || { echo "complete count wrong"; return 1; }
  grep -q '^  duplicate: 1$' <<< "$out" || { echo "duplicate count wrong"; return 1; }
  grep -q '^  wontfix: 1$' <<< "$out" || { echo "wontfix count wrong"; return 1; }
  grep -q '^  todo: 3$' <<< "$out" || { echo "todo group wrong"; return 1; }
  grep -q '^  done: 3$' <<< "$out" || { echo "done group wrong"; return 1; }

  [[ -f "$s" ]] || { echo "statistics.yaml not found"; return 1; }
  grep -q 'total: 6' "$s" || { echo "snapshot not persisted: $(cat "$s")"; return 1; }
  grep -q 'backlog: 1' "$s" || { echo "status counts not persisted: $(cat "$s")"; return 1; }
  grep -q 'todo: 3' "$s" || { echo "group totals not persisted: $(cat "$s")"; return 1; }

  "$TICKETS_CLI" statistics snapshot >/dev/null 2>&1 || { echo "second snapshot failed"; return 1; }
  [[ $(grep -c '^- ts:' "$s") == 2 ]] || { echo "snapshot not appended: $(cat "$s")"; return 1; }

  echo "statistics snapshot records status counts and group totals and appends over time"
}