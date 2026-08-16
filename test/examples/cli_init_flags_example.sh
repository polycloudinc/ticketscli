# cli_init_flags_example
#
# Embedding for the `init` flag variants in the CLI documentation.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()   echoes the code of the fixture this embedding requires
#   run()       emits the transcript (invocation + captured output)

transcript_fence() {
  echo "bash"
}

fixture() {
  echo "f001"
}

run() {
  echo '$ tickets init --code-prefix TKT'
  echo ''
  "$TICKETS_CLI" init --code-prefix TKT
  echo ''
  echo '$ tickets init --code-prefix TKT -d custom_path'
  echo ''
  "$TICKETS_CLI" init --code-prefix TKT -d custom_path
}