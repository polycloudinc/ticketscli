# tc001_init_creates_tickets_dir
#
# Verifies that 'tickets init --code-prefix TST' initializes a tickets
# directory in a project that has none.
#
# Interface contract (this file is sourced by test.sh):
#   fixture()  echoes the code of the fixture this case requires
#   run()      executes the test inside the prepared execution directory;
#              exit 0 = pass, non-zero = fail; echoes an informative message

fixture() {
  echo "f001"
}

run() {
  local init_out
  init_out=$("$TICKETS_CLI" init --code-prefix TST 2>&1) || {
    echo "init exited non-zero: $init_out"
    return 1
  }
  [[ -f .tickets/settings.yaml ]] || { echo "settings.yaml was not created"; return 1; }
  grep -q '^code_prefix: TST$' .tickets/settings.yaml || { echo "code_prefix TST not found in settings.yaml"; return 1; }
  [[ -f .tickets/statistics.yaml ]] || { echo "statistics.yaml was not created"; return 1; }
  echo "init created settings.yaml (prefix TST) and statistics.yaml"
}
