# cli_list_example
#
# Embedding for the `list` example usage in the CLI documentation
# (the previously unpopulated Example usage TODO block).
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
  echo '$ tickets list --status complete'
  echo ''
  "$TICKETS_CLI" list --status complete
}