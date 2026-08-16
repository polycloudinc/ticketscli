# cli_rank_example
#
# Embedding for the `rank` example usage in the CLI documentation:
# inspect the current ticket order, re-rank with `rank first` and
# `rank down`, then list again to see the new order.
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
  echo '$ tickets list'
  echo ''
  "$TICKETS_CLI" list
  echo ''
  echo '$ tickets rank first --ticket TST003'
  echo ''
  "$TICKETS_CLI" rank first --ticket TST003
  echo ''
  echo '$ tickets rank down -t TST002'
  echo ''
  "$TICKETS_CLI" rank down -t TST002
  echo ''
  echo '$ tickets list'
  echo ''
  "$TICKETS_CLI" list
}