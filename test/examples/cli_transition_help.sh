# cli_transition_help
#
# Embedding for the `transition` subcommand `--help` snapshot.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()  echoes the code of the fixture this embedding requires
#   run()      emits the transcript (invocation + captured output)

fixture() {
  echo "f002"
}

run() {
  echo '$ tickets transition --help'
  echo ''
  "$TICKETS_CLI" transition --help
}