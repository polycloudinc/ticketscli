# tc009_cli_error_handling
#
# Verifies CLI error paths: unknown subcommand/option, missing required
# arguments, ambiguous or unknown status/group values, and unknown ticket
# codes all fail with a non-zero exit and a clear error message.

fixture() {
  echo "f003"
}

run() {
  local out

  out=$("$TICKETS_CLI" bogus 2>&1) && { echo "unknown subcommand accepted"; return 1; }
  grep -q 'Unknown subcommand' <<< "$out" || { echo "no unknown-subcommand error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --bogus 2>&1) && { echo "unknown option accepted"; return 1; }
  grep -q 'Unknown option' <<< "$out" || { echo "no unknown-option error: $out"; return 1; }

  out=$("$TICKETS_CLI" create 2>&1) && { echo "create without --name accepted"; return 1; }
  grep -q -- '--name is required' <<< "$out" || { echo "no --name error: $out"; return 1; }

  out=$("$TICKETS_CLI" transition -t TST001 2>&1) && { echo "transition without --target accepted"; return 1; }
  grep -q -- '--target is required' <<< "$out" || { echo "no --target error: $out"; return 1; }

  out=$("$TICKETS_CLI" transition -T complete 2>&1) && { echo "transition without --ticket accepted"; return 1; }
  grep -q -- '--ticket is required' <<< "$out" || { echo "no --ticket error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --status e 2>&1) && { echo "ambiguous status accepted"; return 1; }
  grep -qi 'ambiguous status' <<< "$out" || { echo "no ambiguous-status error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --status zzz 2>&1) && { echo "invalid status accepted"; return 1; }
  grep -qi 'invalid status' <<< "$out" || { echo "no invalid-status error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --group o 2>&1) && { echo "ambiguous group accepted"; return 1; }
  grep -qi 'ambiguous group' <<< "$out" || { echo "no ambiguous-group error: $out"; return 1; }

  out=$("$TICKETS_CLI" list --group zzz 2>&1) && { echo "invalid group accepted"; return 1; }
  grep -qi 'invalid group' <<< "$out" || { echo "no invalid-group error: $out"; return 1; }

  out=$("$TICKETS_CLI" transition -t TST999 -T complete 2>&1) && { echo "unknown ticket accepted"; return 1; }
  grep -q 'no ticket found' <<< "$out" || { echo "no no-ticket error: $out"; return 1; }

  echo "unknown subcommands/options, missing arguments, and ambiguous or unknown values all fail with clear errors"
}