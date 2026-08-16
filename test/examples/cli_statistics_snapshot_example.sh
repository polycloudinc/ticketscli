# cli_statistics_snapshot_example
#
# Embedding for the `statistics snapshot` example usage in the CLI
# documentation: the metrics printed to stdout and the timestamped record
# appended to `.tickets/statistics.yaml`.
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
  echo '$ tickets statistics snapshot'
  echo ''
  "$TICKETS_CLI" statistics snapshot
}

result_description() {
  echo "The snapshot is also appended to \`.tickets/statistics.yaml\` as a timestamped record:"
}

result_file() {
  echo ".tickets/statistics.yaml"
}