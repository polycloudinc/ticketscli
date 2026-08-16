# cli_rank_example
#
# Embedding for the `rank` normalize examples in the CLI documentation.
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
  echo '$ tickets rank'
  echo ''
  "$TICKETS_CLI" rank
  echo ''
  echo '$ tickets rank -d other'
  echo ''
  cp -a .tickets other
  "$TICKETS_CLI" rank -d other
}