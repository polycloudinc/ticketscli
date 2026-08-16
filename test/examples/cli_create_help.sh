# cli_create_help
#
# Embedding for the `create` subcommand `--help` snapshot.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()  echoes the code of the fixture this embedding requires
#   run()      emits the transcript (invocation + captured output)

fixture() {
  echo "f002"
}

run() {
  echo '$ tickets create --help'
  echo ''
  "$TICKETS_CLI" create --help
}