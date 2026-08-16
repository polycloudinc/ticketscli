# cli_statistics_example
#
# Embedding for the `statistics` example in the CLI documentation. The
# command's stdout is captured to a file, which is embedded as the result.
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
  "$TICKETS_CLI" statistics snapshot > metrics.txt
  cat metrics.txt
}

result_description() {
  echo "Metrics are printed to stdout as key-value pairs:"
}

result_file() {
  echo "metrics.txt"
}