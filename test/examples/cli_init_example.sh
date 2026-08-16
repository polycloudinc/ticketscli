# cli_init_example
#
# Embedding for the `init` walkthrough in the CLI documentation: scaffolding
# a fresh project from an uninitialized directory.
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
  echo "f001"
}

run() {
  echo '$ mkdir myproj'
  mkdir myproj
  echo '$ cd myproj'
  cd myproj
  echo '$ git init .'
  echo '$ tickets init --code-prefix MYP'
  "$TICKETS_CLI" init --code-prefix MYP
  echo '$ git add .'
  echo '$ git commit -m "Scaffold project"'
}

result_description() {
  echo "Resultant settings.yaml file in the \`.tickets/\` directory:"
}

result_file() {
  echo "myproj/.tickets/settings.yaml"
}
