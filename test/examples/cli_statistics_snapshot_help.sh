# cli_statistics_snapshot_help
#
# Embedding for the `statistics snapshot` subcommand `--help` snapshot.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()  echoes the code of the fixture this embedding requires
#   run()      emits the transcript (invocation + captured output)

fixture() {
  echo "f002"
}

run() {
  echo '$ tickets statistics snapshot --help'
  echo ''
  "$TICKETS_CLI" statistics snapshot --help
}