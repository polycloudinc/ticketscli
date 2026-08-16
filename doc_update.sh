#!/usr/bin/env bash
#
# doc_update.sh - regenerate scripted CLI snapshots in documentation.
#
# Scans a target Markdown file for embedding marker pairs:
#
#   <!-- <id>:start -->
#   <!-- <id>:end -->
#
# and replaces the content between each pair with content produced by the
# example script test/examples/<id>.sh. Each script is sourced (not
# executed) and follows the same contract as the test cases in test/cases:
#
#   fixture()   echoes the code of the fixture it requires from
#               test/fixtures/ (e.g. f001)
#   run()       emits the transcript: each command echoed with a '$ ' prefix
#               followed by the command's captured stdout/stderr; run() is
#               invoked inside a fresh execution directory under
#               test/executions/ with $TICKETS_CLI set
#
# Optional functions per script:
#
#   transcript_fence()  echoes the fence language for the transcript block
#                       (default: none -> plain code fence)
#   result_description() echoes a short prose paragraph to place between the
#                       transcript and the result block
#   result_file()       echoes a path, relative to the execution directory,
#                       whose contents are embedded in a fenced block after
#                       the transcript (fence language derived from the file
#                       extension: .md -> markdown, .yaml/.yml -> yaml)
#   result_postprocess() reads the result file content on stdin and emits
#                       the transformed content on stdout, applied to the
#                       result file immediately before it is embedded
#                       (e.g. replacing the template's long TODO paragraphs
#                       with a simple 'TODO')
#
# Hand-written text outside the marker pairs is untouched. Markers without a
# corresponding script, and scripts without a marker pair, are warned about
# on stderr. The run exits non-zero when no embeddings were found or when the
# target file does not exist.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
EXAMPLES_DIR="$SCRIPT_DIR/test/examples"
FIXTURES_DIR="$SCRIPT_DIR/test/fixtures"
EXECUTIONS_DIR="$SCRIPT_DIR/test/executions"
TICKETS_CLI="$SCRIPT_DIR/tickets.sh"

usage() {
  cat <<EOF
Usage: doc_update.sh [--file <markdown-file>]

Options:
  --file <path>  Target Markdown file (default: \$SCRIPT_DIR/Tickets System.md)
  -h, --help     Show this help message
EOF
}

target="$SCRIPT_DIR/Tickets System.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      [[ -z "${2:-}" ]] && { echo "Error: --file requires a path argument" >&2; exit 1; }
      target="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "$target" != /* ]]; then
  target="$(pwd)/$target"
fi

if [[ ! -f "$target" ]]; then
  echo "Error: target file not found: $target" >&2
  exit 1
fi

if [[ ! -d "$EXAMPLES_DIR" ]] || ! compgen -G "$EXAMPLES_DIR/*.sh" >/dev/null; then
  echo "Error: no example scripts found in $EXAMPLES_DIR" >&2
  exit 1
fi

if [[ ! -f "$TICKETS_CLI" ]]; then
  echo "Error: CLI not found: $TICKETS_CLI" >&2
  exit 1
fi

# Run one example script and emit the content to embed between its markers.
# Emits the fenced transcript, optionally followed by the description prose
# and the fenced result file. Non-zero on any failure.
run_example() {
  local id="$1"
  local ex_file="$EXAMPLES_DIR/$id.sh"

  unset -f fixture run transcript_fence result_description result_file result_postprocess 2>/dev/null || true
  # shellcheck disable=SC1090
  source "$ex_file"
  if ! declare -F fixture >/dev/null || ! declare -F run >/dev/null; then
    echo "Error: example script $id.sh must define 'fixture' and 'run' functions" >&2
    return 1
  fi

  local fcode fstatus fixture_matches
  set +e
  fcode=$(fixture)
  fstatus=$?
  set -e
  fcode=${fcode%$'\n'}
  if [[ $fstatus -ne 0 || -z "$fcode" ]]; then
    echo "Error: fixture() did not return a fixture code for '$id'" >&2
    return 1
  fi
  fixture_matches=("$FIXTURES_DIR/$fcode"_*)
  if [[ ! -d "${fixture_matches[0]}" ]]; then
    echo "Error: fixture '$fcode' not found in $FIXTURES_DIR (for '$id')" >&2
    return 1
  fi

  local ts exec_dir
  ts=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
  exec_dir="$EXECUTIONS_DIR/${id}_${ts}"
  if [[ -e "$exec_dir" ]]; then
    echo "Error: execution directory already exists: $exec_dir" >&2
    return 1
  fi
  mkdir -p "$exec_dir"
  cp -a "${fixture_matches[0]}/." "$exec_dir/"

  local output status
  set +e
  output=$(cd "$exec_dir" && TICKETS_CLI="$TICKETS_CLI" run 2>&1)
  status=$?
  set -e
  if [[ $status -ne 0 ]]; then
    echo "Error: example script '$id' run() exited $status: $output" >&2
    return 1
  fi

  # Normalize variable content so re-runs are deterministic: strip the
  # execution directory path (e.g. 'Created: <abs>/execdir/.tickets/...')
  # and replace ISO 8601 UTC timestamps with a fixed placeholder.
  output=$(printf '%s\n' "$output" | sed -E "s|$exec_dir/||g; s|[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z|2026-01-01T00:00:00Z|g")
  output=${output%$'\n'}

  local fence_lang=""
  if declare -F transcript_fence >/dev/null; then
    fence_lang=$(transcript_fence)
    fence_lang=${fence_lang%$'\n'}
  fi

  local desc=""
  if declare -F result_description >/dev/null; then
    desc=$(result_description)
  fi

  local rfile=""
  if declare -F result_file >/dev/null; then
    rfile=$(result_file)
    rfile=${rfile%$'\n'}
  fi

  printf '%s\n' "\`\`\`$fence_lang"
  printf '%s\n' "$output"
  printf '%s\n' '```'
  if [[ -n "$desc" ]]; then
    printf '%s\n' "" "$desc"
  fi
  if [[ -n "$rfile" ]]; then
    local rpath="$exec_dir/$rfile"
    if [[ ! -f "$rpath" ]]; then
      echo "Error: result file '$rfile' not found in execution directory (for '$id')" >&2
      return 1
    fi
    local rfence=""
    case "$rfile" in
      *.md|*.markdown) rfence="markdown" ;;
      *.yaml|*.yml)    rfence="yaml" ;;
    esac
    local rcontent
    if declare -F result_postprocess >/dev/null; then
      rcontent=$(sed -E "s|[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z|2026-01-01T00:00:00Z|g" "$rpath" | result_postprocess)
    else
      rcontent=$(sed -E "s|[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z|2026-01-01T00:00:00Z|g" "$rpath")
    fi
    printf '%s\n' "" "\`\`\`$rfence"
    printf '%s\n' "$rcontent"
    printf '%s\n' '```'
  fi
}

declare -A seen_ids=()
found_markers=0
current_id=""
buffer=()

start_re='^<!-- (cli_[a-z0-9_]+):start -->$'
end_re='^<!-- (cli_[a-z0-9_]+):end -->$'

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ $start_re ]]; then
    id="${BASH_REMATCH[1]}"
    found_markers=$((found_markers + 1))
    seen_ids[$id]=1
    buffer+=("$line")
    if [[ -n "$current_id" ]]; then
      echo "Warning: start marker '$id' found while '$current_id' is still open" >&2
    fi
    if [[ ! -f "$EXAMPLES_DIR/$id.sh" ]]; then
      echo "Warning: unknown embedding identifier '$id' (no test/examples/$id.sh; start marker left untouched)" >&2
      continue
    fi
    if ! run_example "$id" > /tmp/example_block_$$; then
      exit 1
    fi
    while IFS= read -r bline || [[ -n "$bline" ]]; do
      buffer+=("$bline")
    done < /tmp/example_block_$$
    rm -f /tmp/example_block_$$
    buffer+=("")
    current_id="$id"
    continue
  fi

  if [[ "$line" =~ $end_re ]]; then
    id="${BASH_REMATCH[1]}"
    if [[ -n "$current_id" ]]; then
      if [[ "$id" == "$current_id" ]]; then
        current_id=""
      else
        echo "Warning: end marker '$id' found while '$current_id' is still open" >&2
        current_id=""
      fi
    else
      echo "Warning: end marker '$id' without a matching start marker" >&2
    fi
    buffer+=("$line")
    continue
  fi

  if [[ -n "$current_id" ]]; then
    continue
  fi
  buffer+=("$line")
done < "$target"

if [[ -n "$current_id" ]]; then
  echo "Warning: start marker '$current_id' without a matching end marker" >&2
fi

local_f="$EXAMPLES_DIR"/*.sh
for f in $local_f; do
  [[ -f "$f" ]] || continue
  id=$(basename "$f" .sh)
  if [[ -z "${seen_ids[$id]:-}" ]]; then
    echo "Warning: example script '$id.sh' has no marker pair in $target" >&2
  fi
done

if [[ $found_markers -eq 0 ]]; then
  echo "Error: no embedding markers found in $target" >&2
  exit 1
fi

tmp_file=$(mktemp "${target}.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT
printf '%s\n' "${buffer[@]}" > "$tmp_file"
mv "$tmp_file" "$target"
trap - EXIT

echo "Updated $found_markers embedding(s) in $target"