# cli_rank_mutations_example
#
# Embedding for the `rank` mutation examples (up/down/first/last) in the
# CLI documentation.
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
  echo '$ tickets rank up --ticket TST003'
  echo ''
  "$TICKETS_CLI" rank up --ticket TST003
  echo ''
  echo '$ tickets rank down -t TST001'
  echo ''
  "$TICKETS_CLI" rank down -t TST001
  echo ''
  echo '$ tickets rank first --ticket TST003'
  echo ''
  "$TICKETS_CLI" rank first --ticket TST003
  echo ''
  echo '$ tickets rank last -t TST003'
  echo ''
  "$TICKETS_CLI" rank last -t TST003
}