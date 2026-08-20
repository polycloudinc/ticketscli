# tc003_list_table_output
#
# Verifies 'tickets list' table rendering: header columns, ascending rank
# sort, '-' rank for done tickets, long-subject truncation, and the summary
# line.

fixture() {
  echo "f003"
}

run() {
  local out
  out=$("$TICKETS_CLI" list 2>&1) || { echo "list failed: $out"; return 1; }

  grep -q 'Code' <<< "$out" || { echo "Code header missing"; return 1; }
  grep -q 'Subject' <<< "$out" || { echo "Subject header missing"; return 1; }
  grep -q 'Rank' <<< "$out" || { echo "Rank header missing"; return 1; }
  grep -q 'Status' <<< "$out" || { echo "Status header missing"; return 1; }

  # Ascending rank order: TST002 (1) before TST001 (2) before TST003 (3)
  local l2 l1 l3
  l2=$(grep -n 'TST002' <<< "$out" | head -1 | cut -d: -f1)
  l1=$(grep -n 'TST001' <<< "$out" | head -1 | cut -d: -f1)
  l3=$(grep -n 'TST003' <<< "$out" | head -1 | cut -d: -f1)
  [[ -n "$l2" && -n "$l1" && -n "$l3" ]] || { echo "expected ticket rows missing"; return 1; }
  (( l2 < l1 && l1 < l3 )) || { echo "rows not in ascending rank order"; return 1; }

  # Done tickets display '-' in the rank column
  grep -E 'TST004\s+.*\s-\s+complete' <<< "$out" >/dev/null || { echo "TST004 rank is not '-'"; return 1; }
  grep -E 'TST006\s+.*\s-\s+wontfix' <<< "$out" >/dev/null || { echo "TST006 rank is not '-'"; return 1; }

  # Summary line
  grep -q '^6 matching from 6 total tickets$' <<< "$out" || { echo "summary line wrong: $(tail -1 <<< "$out")"; return 1; }

  # Long subjects are truncated with an ellipsis (200 chars fits within the
  # 255-byte filename limit but exceeds any normal terminal width)
  local long_name
  long_name=$(printf 'Long%.0s' {1..50})
  "$TICKETS_CLI" create -n "$long_name" >/dev/null 2>&1 || { echo "create of long-name ticket failed"; return 1; }
  out=$("$TICKETS_CLI" list 2>&1) || { echo "list after create failed: $out"; return 1; }
  grep -q '\.\.\.' <<< "$out" || { echo "long subject not truncated with ellipsis"; return 1; }

  echo "list renders a ranked table with '-' for done tickets, truncated subjects, and a summary line"
}
