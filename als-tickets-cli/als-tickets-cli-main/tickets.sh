#!/usr/bin/env bash
set -euo pipefail

TICKETS_DIR="_tickets"

filter=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --backlog|-b|--active|-a|--done|-d)
      [[ -n "$filter" ]] && { echo "Error: only one of --backlog, --active, --done may be specified" >&2; exit 1; }
      case "$1" in
        --backlog|-b) filter="--backlog" ;;
        --active|-a)  filter="--active" ;;
        --done|-d)    filter="--done" ;;
      esac
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

printf "%-8s %-50s %-12s\n" "Code" "Subject" "Status"
printf "%-8s %-50s %-12s\n" "----" "-------" "------"

for ticket in "$TICKETS_DIR"/*.md; do
  [[ "$ticket" == "$TICKETS_DIR/.gitkeep" ]] && continue
  [[ -f "$ticket" ]] || continue

  filename=$(basename "$ticket")
  number="${filename%% *}"

  frontmatter=$(sed -n '/^---$/,/^---$/p' "$ticket")
  subject=$(echo "$frontmatter" | grep '^name:' | sed 's/^name: //')
  [[ ${#subject} -gt 50 ]] && subject="${subject:0:47}..."
  status=$(echo "$frontmatter" | grep '^ticket_status:' | sed 's/^ticket_status: //' | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')

  case "$filter" in
    --backlog) [[ "$status" != "Backlog" ]] && continue ;;
    --active)  [[ "$status" != "Ready" && "$status" != "In Progress" ]] && continue ;;
    --done)    [[ "$status" != "Done" && "$status" != "Won't Fix" ]] && continue ;;
  esac

  printf "%-8s %-50s %-12s\n" "$number" "$subject" "$status"
done
