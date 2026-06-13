#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: tickets <subcommand> [options]

Subcommands:
  list        List tickets from the tickets directory

Options:
  -h, --help  Show this help message
EOF
}

list_usage() {
  cat <<EOF
Usage: tickets list [options]

Options:
  -t, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -g, --group <backlog|active|done>  Filter tickets by status group
  -s, --status <status>    Filter by status (exact or distinguishing substring, case-insensitive)
  -h, --help                Show this help message
EOF
}

cmd_list() {
  local tickets_dir="_tickets"
  local filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -g|--group)
        [[ -z "${2:-}" ]] && { echo "Error: -g/--group requires a value (backlog, active, or done)" >&2; exit 1; }
        [[ -n "$filter" ]] && { echo "Error: only one filter option may be specified" >&2; exit 1; }
        group_val_lower=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        known=(backlog active done)
        resolved=""
        for k in "${known[@]}"; do
          if [[ "$k" == "$group_val_lower" ]]; then
            resolved="$k"
            break
          fi
        done
        if [[ -z "$resolved" ]]; then
          matches=()
          for k in "${known[@]}"; do
            [[ "$k" == *"$group_val_lower"* ]] && matches+=("$k")
          done
          if [[ ${#matches[@]} -eq 1 ]]; then
            resolved="${matches[0]}"
          elif [[ ${#matches[@]} -eq 0 ]]; then
            echo "Error: invalid group '$2'. Valid groups: backlog, active, done" >&2
            exit 1
          else
            echo "Error: ambiguous group '$2'. Matches: ${matches[*]}" >&2
            exit 1
          fi
        fi
        filter="$resolved"
        shift
        ;;
      -s|--status)
        [[ -z "${2:-}" ]] && { echo "Error: -s/--status requires a status value" >&2; exit 1; }
        [[ -n "$filter" ]] && { echo "Error: only one filter option may be specified" >&2; exit 1; }
        status_val_lower=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        known=(backlog ready "in progress" complete duplicate "won't fix")
        resolved=""
        for k in "${known[@]}"; do
          if [[ "$k" == "$status_val_lower" ]]; then
            resolved="$k"
            break
          fi
        done
        if [[ -z "$resolved" ]]; then
          matches=()
          for k in "${known[@]}"; do
            [[ "$k" == *"$status_val_lower"* ]] && matches+=("$k")
          done
          if [[ ${#matches[@]} -eq 1 ]]; then
            resolved="${matches[0]}"
          elif [[ ${#matches[@]} -eq 0 ]]; then
            echo "Error: invalid status '$2'. Valid statuses: Backlog, Ready, \"In Progress\", Complete, Duplicate, Won't Fix" >&2
            exit 1
          else
            echo "Error: ambiguous status '$2'. Matches: ${matches[*]}" >&2
            exit 1
          fi
        fi
        filter="status:$resolved"
        shift
        ;;
      -h|--help)
        list_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets list --help' for usage." >&2
        exit 1
        ;;
    esac
    shift
  done

  printf "%-8s %-50s %-12s\n" "Code" "Subject" "Status"
  printf "%-8s %-50s %-12s\n" "----" "-------" "------"

  for ticket in "$tickets_dir"/*.md; do
    [[ "$ticket" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$ticket" ]] || continue

    filename=$(basename "$ticket")
    number="${filename%% *}"

    frontmatter=$(sed -n '/^---$/,/^---$/p' "$ticket")
    subject=$(echo "$frontmatter" | grep '^name:' | sed 's/^name: //')
    [[ ${#subject} -gt 50 ]] && subject="${subject:0:47}..."
    status=$(echo "$frontmatter" | grep '^ticket_status:' | sed 's/^ticket_status: //' | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')

    case "$filter" in
      backlog) [[ "$status" != "Backlog" ]] && continue ;;
      active)  [[ "$status" != "Ready" && "$status" != "In Progress" ]] && continue ;;
      done)    [[ "$status" != "Complete" && "$status" != "Duplicate" && "$status" != "Won't Fix" ]] && continue ;;
      status:*)
        expected="${filter#status:}"
        status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')
        [[ "$status_lower" != "$expected" ]] && continue
        ;;
    esac

    printf "%-8s %-50s %-12s\n" "$number" "$subject" "$status"
  done
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

subcommand="$1"
shift

case "$subcommand" in
  -h|--help)
    usage
    ;;
  list)
    cmd_list "$@"
    ;;
  *)
    echo "Unknown subcommand: $subcommand" >&2
    usage
    exit 1
    ;;
esac
