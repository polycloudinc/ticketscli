#!/usr/bin/env bash
#
# doc_update.sh - regenerate CLI help snapshots in documentation.
#
# Scans a target Markdown file for embedding marker pairs:
#
#   <!-- cli_<id>:start -->
#   <!-- cli_<id>:end -->
#
# and replaces the content between each pair with a code-fenced snapshot of
# the live `--help` output for the mapped subcommand. Hand-written text
# outside the marker pairs is untouched.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

usage() {
  cat <<EOF
Usage: doc_update.sh [--file <markdown-file>]

Options:
  --file <path>  Target Markdown file (default: \$SCRIPT_DIR/Tickets System.md)
  -h, --help     Show this help message
EOF
}

# Map an embedding identifier to the subcommand arguments that produce its
# help output. Returns non-zero for unknown identifiers.
embed_args() {
  local id="$1"
  case "$id" in
    cli_init)       echo "init" ;;
    cli_create)     echo "create" ;;
    cli_list)       echo "list" ;;
    cli_validate)   echo "validate" ;;
    cli_transition) echo "transition" ;;
    cli_statistics) echo "statistics" ;;
    cli_rank_up)    echo "rank up" ;;
    cli_rank_down)  echo "rank down" ;;
    cli_rank_first) echo "rank first" ;;
    cli_rank_last)  echo "rank last" ;;
    *) return 1 ;;
  esac
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

declare -A help_cache=()
found_markers=0
current_id=""
result=""
buffer=()

start_re='^<!-- (cli_[a-z0-9_]+):start -->$'
end_re='^<!-- (cli_[a-z0-9_]+):end -->$'

capture_help() {
  local id="$1"
  local args output
  if [[ -n "${help_cache[$id]:-}" ]]; then
    return 0
  fi
  args=$(embed_args "$id") || return 1
  output=$("$SCRIPT_DIR/tickets.sh" $args --help) || {
    echo "Error: failed to run '$SCRIPT_DIR/tickets.sh $args --help'" >&2
    return 1
  }
  help_cache[$id]="$output"
}

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ $start_re ]]; then
    id="${BASH_REMATCH[1]}"
    found_markers=$((found_markers + 1))
    buffer+=("$line")
    if ! embed_args "$id" >/dev/null 2>&1; then
      echo "Warning: unknown embedding identifier '$id' (start marker left untouched)" >&2
      continue
    fi
    if [[ -n "$current_id" ]]; then
      echo "Warning: start marker '$id' found while '$current_id' is still open" >&2
    fi
    if ! capture_help "$id"; then
      exit 1
    fi
    current_id="$id"
    invocation="tickets $(embed_args "$id") --help"
    buffer+=("" '```' "$invocation" "" "${help_cache[$id]}" '```' "")
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