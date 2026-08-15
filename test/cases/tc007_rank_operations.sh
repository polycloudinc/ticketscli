# tc007_rank_operations
#
# Verifies 'tickets rank' reordering: rank up/down swaps, rank first/last
# shifts, normalization closing gaps, done-ticket exclusion, and the
# already-at-extreme messages.

fixture() {
  echo "f003"
}

rank_of() {
  grep '^ticket_rank:' ".tickets/$1" | awk '{print $2}'
}

run() {
  local f1="TST001 - Alpha Ticket.md"
  local f2="TST002 - Bravo Ticket.md"
  local f3="TST003 - Charlie Ticket.md"
  local f4="TST004 - Delta Ticket.md"
  local f6="TST006 - Foxtrot Ticket.md"
  local out

  [[ $(rank_of "$f2") == 1 && $(rank_of "$f1") == 2 && $(rank_of "$f3") == 3 ]] || { echo "baseline ranks wrong"; return 1; }

  "$TICKETS_CLI" rank up -t TST001 >/dev/null 2>&1 || { echo "rank up failed"; return 1; }
  [[ $(rank_of "$f1") == 1 && $(rank_of "$f2") == 2 ]] || { echo "rank up did not swap"; return 1; }

  out=$("$TICKETS_CLI" rank up -t TST001 2>&1) || { echo "rank up at top exited non-zero"; return 1; }
  grep -q 'already at the highest priority' <<< "$out" || { echo "no highest-priority message: $out"; return 1; }

  "$TICKETS_CLI" rank down -t TST001 >/dev/null 2>&1 || { echo "rank down failed"; return 1; }
  [[ $(rank_of "$f1") == 2 && $(rank_of "$f2") == 1 ]] || { echo "rank down did not swap"; return 1; }

  "$TICKETS_CLI" rank first -t TST003 >/dev/null 2>&1 || { echo "rank first failed"; return 1; }
  [[ $(rank_of "$f3") == 1 && $(rank_of "$f2") == 2 && $(rank_of "$f1") == 3 ]] || { echo "rank first shift wrong"; return 1; }

  "$TICKETS_CLI" rank last -t TST003 >/dev/null 2>&1 || { echo "rank last failed"; return 1; }
  [[ $(rank_of "$f3") == 3 && $(rank_of "$f2") == 1 && $(rank_of "$f1") == 2 ]] || { echo "rank last shift wrong"; return 1; }

  # Normalization closes gaps: inject a rank of 9 for TST003
  sed -i 's/^ticket_rank:.*$/ticket_rank: 9/' ".tickets/$f3"
  "$TICKETS_CLI" rank >/dev/null 2>&1 || { echo "rank normalization failed"; return 1; }
  [[ $(rank_of "$f2") == 1 && $(rank_of "$f1") == 2 && $(rank_of "$f3") == 3 ]] || { echo "normalization did not close the gap"; return 1; }

  # Done tickets are excluded from ranking (their rank reads as empty/null)
  [[ $(rank_of "$f4") == "" || $(rank_of "$f4") == "null" ]] || { echo "complete ticket got a rank"; return 1; }
  [[ $(rank_of "$f6") == "" || $(rank_of "$f6") == "null" ]] || { echo "wont-fix ticket got a rank"; return 1; }

  echo "rank up/down/first/last reorder correctly, normalization closes gaps, done tickets stay unranked"
}