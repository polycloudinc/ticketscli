# tc010_tickets_dir_resolution
#
# Verifies tickets-directory resolution: with neither directory present the
# default `.tickets` is used; `_tickets` alone works with a deprecation
# warning; both present is an error; and `--tickets-dir` overrides.

fixture() {
  echo "f001"
}

run() {
  local out

  # Neither directory present: defaults to .tickets and lists zero tickets
  out=$("$TICKETS_CLI" list 2>&1) || { echo "list with no dirs failed: $out"; return 1; }
  grep -q '^0 matching from 0 total tickets$' <<< "$out" || { echo "unexpected default output: $out"; return 1; }

  # _tickets alone: works with a deprecation warning
  mkdir _tickets
  out=$("$TICKETS_CLI" list 2>&1) || { echo "list with _tickets failed: $out"; return 1; }
  grep -qi 'deprecated' <<< "$out" || { echo "no deprecation warning: $out"; return 1; }

  # Both directories present: error
  mkdir .tickets
  out=$("$TICKETS_CLI" list 2>&1) && { echo "both dirs accepted"; return 1; }
  grep -q 'both .tickets and _tickets' <<< "$out" || { echo "no both-dirs error: $out"; return 1; }

  # --tickets-dir overrides resolution entirely
  mkdir custom_tickets
  out=$("$TICKETS_CLI" list --tickets-dir custom_tickets 2>&1) || { echo "list --tickets-dir failed: $out"; return 1; }
  grep -q '^0 matching from 0 total tickets$' <<< "$out" || { echo "unexpected override output: $out"; return 1; }

  echo "dir resolution defaults to .tickets, deprecates _tickets, errors on both, and honors --tickets-dir"
}