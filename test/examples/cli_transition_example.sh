# cli_transition_example
#
# Embedding for the `transition` example usage in the CLI documentation,
# including a transition to a done status and the transitioned ticket file.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()   echoes the code of the fixture this embedding requires
#   run()       emits the transcript (invocation + captured output)
#   result_description() echoes a prose paragraph before the result block
#   result_file()   echoes a path (relative to the execution directory)
#                   whose contents are embedded after the transcript

transcript_fence() {
  echo "bash"
}

fixture() {
  echo "f003"
}

run() {
  echo '$ tickets list'
  echo ''
  "$TICKETS_CLI" list
  echo ''
  echo '$ tickets transition --ticket TST001 --target inprogress'
  echo ''
  "$TICKETS_CLI" transition --ticket TST001 --target inprogress
  echo ''
  echo '$ tickets list'
  echo ''
  "$TICKETS_CLI" list
  echo ''
  echo '$ tickets transition -t TST001 -T complete'
  echo ''
  "$TICKETS_CLI" transition -t TST001 -T complete
  echo ''
  echo '$ tickets list'
  echo ''
  "$TICKETS_CLI" list
  echo ''
  echo '$ cp -a .tickets other'
  echo ''
  cp -a .tickets other
  echo ''
  echo '$ tickets list -d other'
  echo ''
  "$TICKETS_CLI" list -d other
  echo ''
  echo '$ tickets transition --ticket TST003 --target ready -d other'
  echo ''
  "$TICKETS_CLI" transition --ticket TST003 --target ready -d other
  echo ''
  echo '$ tickets list -d other'
  echo ''
  "$TICKETS_CLI" list -d other
}

result_description() {
  echo "Transitioned ticket file:"
}

result_file() {
  echo ".tickets/TST001 - Alpha Ticket.md"
}