# cli_validate_help
#
# Embedding for the `validate` subcommand `--help` snapshot.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()  echoes the code of the fixture this embedding requires
#   run()      emits the transcript (invocation + captured output)

transcript_fence() {
  echo "bash"
}

fixture() {
  echo "f002"
}

run() {
  echo '$ tickets validate --help'
  echo ''
  "$TICKETS_CLI" validate --help
}