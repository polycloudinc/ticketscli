# cli_create_example
#
# Embedding for the `create` walkthrough in the CLI documentation,
# including the resultant ticket file.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()   echoes the code of the fixture this embedding requires
#   run()       emits the transcript (invocation + captured output)
#   result_description() echoes a prose paragraph before the result block
#   result_file()   echoes a path (relative to the execution directory)
#                   whose contents are embedded after the transcript
#   result_postprocess() reads the result file content on stdin and emits
#                   the transformed content on stdout

transcript_fence() {
  echo "bash"
}

fixture() {
  echo "f004"
}

run() {
  echo '$ tickets create --name "Add database connection pool to service"'
  echo ''
  "$TICKETS_CLI" create --name "Add database connection pool to service"
  echo ''
  echo '$ tickets create -n "Fix Bug"'
  echo ''
  "$TICKETS_CLI" create -n "Fix Bug"
}

result_description() {
  echo "Resultant ticket file:"
}

result_file() {
  echo ".tickets/MYP001 - Add database connection pool to service.md"
}

result_postprocess() {
  sed -E 's/^TODO: .*$/TODO/'
}