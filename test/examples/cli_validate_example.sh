# cli_validate_example
#
# Embedding for the `validate` example usage in the CLI documentation:
# single-ticket validation and a custom tickets directory.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()   echoes the code of the fixture this embedding requires
#   run()       emits the transcript (invocation + captured output)

transcript_fence() {
  echo "bash"
}

fixture() {
  echo "f003"
}

run() {
  echo '$ tickets validate --ticket TST001'
  echo ''
  "$TICKETS_CLI" validate --ticket TST001
  echo ''
  echo '$ tickets validate --ticket TST001 -d other'
  echo ''
  cp -a .tickets other
  "$TICKETS_CLI" validate --ticket TST001 -d other
}