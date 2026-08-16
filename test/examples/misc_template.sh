# misc_template
#
# Embedding for the raw ticket template (front matter) shipped alongside
# tickets.sh, kept in sync with the actual template file.
#
# Interface contract (this file is sourced by doc_update.sh):
#   fixture()   echoes the code of the fixture this embedding requires
#   run()       emits the transcript (invocation + captured output)

transcript_fence() {
  echo "markdown"
}

fixture() {
  echo "f002"
}

run() {
  local template_file
  template_file="$(dirname "$(readlink -f "$TICKETS_CLI")")/Ticket.md"
  awk '/^---$/{c++; print; if (c == 2) exit; next} c == 1 {print}' "$template_file"
}