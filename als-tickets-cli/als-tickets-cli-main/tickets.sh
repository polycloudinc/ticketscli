#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

check_dependencies() {
  if ! command -v python3 &>/dev/null; then
    echo "Error: python3 is required but not installed." >&2
    echo "Install it with your system package manager (e.g., apt install python3)." >&2
    exit 1
  fi
  if ! python3 -c "import yaml" &>/dev/null; then
    echo "Error: PyYAML is required but not installed." >&2
    echo "Install it with: pip install pyyaml" >&2
    exit 1
  fi
  if [[ ! -f "$SCRIPT_DIR/yz.py" ]]; then
    echo "Error: yz.py not found alongside tickets.sh ($SCRIPT_DIR/yz.py)" >&2
    exit 1
  fi
}

usage() {
  cat <<EOF
Usage: tickets <subcommand> [options]

Subcommands:
  init              Initialize the tickets directory structure
  list              List tickets from the tickets directory
  validate          Validate a ticket's front matter against the schema
  create            Create a new ticket file
  transition        Transition a ticket to a new status
  rank              Normalize ticket ranks across all tickets
  rank up           Promote a ticket's priority
  rank down         Demote a ticket's priority
  rank first        Move a ticket to rank 1
  rank last         Move a ticket to the lowest rank
  statistics snapshot  Record a statistics snapshot to _tickets/statistics.yaml

Options:
  -h, --help  Show this help message
EOF
}

list_usage() {
  cat <<EOF
Usage: tickets list [options]

Output is sorted ascending by ticket_rank. Tickets without a rank or with
a non-integer rank value sort last.

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -g, --group <backlog|active|done|todo>  Filter tickets by status group
  -l, --limit <N>           Limit output to the first N tickets after filtering and sorting
  -s, --status <status>    Filter by status (exact or distinguishing substring, case-insensitive)
  -h, --help                Show this help message
EOF
}

validate_usage() {
  cat <<EOF
Usage: tickets validate [--all | --ticket <code>] [options]

Options:
  -a, --all                 Validate all tickets
  -t, --ticket <code>       Validate a single ticket by code
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
EOF
}

create_usage() {
  cat <<EOF
Usage: tickets create --name <subject> [options]

Options:
  -n, --name <subject>       Subject/name for the new ticket (required)
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
EOF
}

rank_usage() {
  cat <<EOF
Usage: tickets rank [options]

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                 Show this help message
EOF
}

rank_up_usage() {
  cat <<EOF
Usage: tickets rank up --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to promote
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
EOF
}

rank_down_usage() {
  cat <<EOF
Usage: tickets rank down --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to demote
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
EOF
}

rank_first_usage() {
  cat <<EOF
Usage: tickets rank first --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to move to rank 1
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
EOF
}

rank_last_usage() {
  cat <<EOF
Usage: tickets rank last --ticket <code> [options]

Options:
  -t, --ticket <code>        Ticket code to move to the lowest rank
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
EOF
}

transition_usage() {
  cat <<EOF
Usage: tickets transition --ticket <code> --target <status> [options]

Options:
  -t, --ticket <code>        Ticket code to transition
  -T, --target <status>      Target status (backlog, ready, inprogress, complete, duplicate, wontfix; case-insensitive, fuzzy-matched)
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  -h, --help                  Show this help message
EOF
}

statistics_usage() {
  cat <<EOF
Usage: tickets statistics snapshot [options]

Options:
  -d, --tickets-dir <path>  Path to tickets directory (default: _tickets)
  -h, --help                Show this help message
EOF
}

init_usage() {
  cat <<EOF
Usage: tickets init [options]

Options:
  -d, --tickets-dir <path>   Path to tickets directory (default: _tickets)
  --code-prefix <prefix>      Ticket code prefix (3-4 alpha characters)
  -h, --help                  Show this help message
EOF
}

normalize_ranks() {
  local tickets_dir="$1"
  local tmpfile
  tmpfile=$(mktemp)

  for ticket in "$tickets_dir"/*.md; do
    [[ "$ticket" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$ticket" ]] || continue

    local status
    status=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket" .ticket_status | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')

    case "$status" in
      "Complete"|"Duplicate"|"Won't Fix")
        local old_rank
        old_rank=$(get_ticket_rank "$ticket")
        python3 "$SCRIPT_DIR/yz.py" update "$ticket" .ticket_rank null
        sed -i 's/^ticket_rank: null$/ticket_rank:/' "$ticket"
        if [[ -n "$old_rank" ]]; then
          touch_ticket_updated "$ticket"
        fi
        continue
        ;;
    esac

    local rank_val
    rank_val=$(get_ticket_rank "$ticket")

    if [[ "$rank_val" =~ ^[0-9]+$ ]]; then
      printf '%d\t%s\n' "$rank_val" "$ticket" >> "$tmpfile"
    else
      printf '%d\t%s\n' 999999 "$ticket" >> "$tmpfile"
    fi
  done

  local new_rank=1
  local count=0
  local ticket_file
  while IFS=$'\t' read -r old_rank ticket_file; do
    set_ticket_rank "$ticket_file" "$new_rank"
    new_rank=$((new_rank + 1))
    count=$((count + 1))
  done < <(sort -t$'\t' -k1 -n -k2 "$tmpfile")

  rm -f "$tmpfile"
  echo "$count ticket(s) normalized."
}

find_ticket_by_code() {
  local tickets_dir="$1"
  local code="$2"
  for f in "$tickets_dir"/"$code"*.md; do
    [[ -f "$f" ]] && { echo "$f"; return 0; }
  done
  return 1
}

get_ticket_rank() {
  local ticket_file="$1"
  python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_rank
}

set_ticket_rank() {
  local ticket_file="$1"
  local new_rank="$2"
  local old_rank
  old_rank=$(get_ticket_rank "$ticket_file")
  python3 "$SCRIPT_DIR/yz.py" update "$ticket_file" .ticket_rank "$new_rank"
  if [[ "$old_rank" != "$new_rank" ]]; then
    touch_ticket_updated "$ticket_file"
  fi
}

touch_ticket_updated() {
  local ticket_file="$1"
  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  TS="$ts" python3 "$SCRIPT_DIR/yz.py" set-env "$ticket_file" .ticket_updated TS
}

cmd_rank_up() {
  check_dependencies
  local tickets_dir="_tickets"
  local ticket_code=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--ticket)
        [[ -z "${2:-}" ]] && { echo "Error: --ticket requires a ticket code" >&2; exit 1; }
        ticket_code="$2"
        shift
        ;;
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        rank_up_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        rank_up_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$ticket_code" ]]; then
    echo "Error: --ticket is required" >&2
    rank_up_usage
    exit 1
  fi

  normalize_ranks "$tickets_dir"

  local target_file
  target_file=$(find_ticket_by_code "$tickets_dir" "$ticket_code")
  if [[ -z "$target_file" ]]; then
    echo "Error: no ticket found for code '$ticket_code'" >&2
    exit 1
  fi

  local target_rank
  target_rank=$(get_ticket_rank "$target_file")

  if [[ "$target_rank" -eq 1 ]]; then
    echo "Ticket $ticket_code is already at the highest priority."
    return 0
  fi

  local new_rank=$((target_rank - 1))
  local other_file=""
  for f in "$tickets_dir"/*.md; do
    [[ "$f" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$f" ]] || continue
    local r
    r=$(get_ticket_rank "$f")
    [[ "$r" -eq "$new_rank" ]] && { other_file="$f"; break; }
  done

  if [[ -z "$other_file" ]]; then
    echo "Error: could not find ticket at rank $new_rank" >&2
    exit 1
  fi

  set_ticket_rank "$target_file" "$new_rank"
  set_ticket_rank "$other_file" "$target_rank"
  echo "Promoted $ticket_code to rank $new_rank."
}

cmd_rank_down() {
  check_dependencies
  local tickets_dir="_tickets"
  local ticket_code=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--ticket)
        [[ -z "${2:-}" ]] && { echo "Error: --ticket requires a ticket code" >&2; exit 1; }
        ticket_code="$2"
        shift
        ;;
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        rank_down_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        rank_down_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$ticket_code" ]]; then
    echo "Error: --ticket is required" >&2
    rank_down_usage
    exit 1
  fi

  normalize_ranks "$tickets_dir"

  local target_file
  target_file=$(find_ticket_by_code "$tickets_dir" "$ticket_code")
  if [[ -z "$target_file" ]]; then
    echo "Error: no ticket found for code '$ticket_code'" >&2
    exit 1
  fi

  local target_rank
  target_rank=$(get_ticket_rank "$target_file")

  local max_rank=0
  for f in "$tickets_dir"/*.md; do
    [[ "$f" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$f" ]] || continue
    local r
    r=$(get_ticket_rank "$f")
    [[ "$r" =~ ^[0-9]+$ && "$r" -gt "$max_rank" ]] && max_rank="$r"
  done

  if [[ "$target_rank" -eq "$max_rank" ]]; then
    echo "Ticket $ticket_code is already at the lowest priority."
    return 0
  fi

  local new_rank=$((target_rank + 1))
  local other_file=""
  for f in "$tickets_dir"/*.md; do
    [[ "$f" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$f" ]] || continue
    local r
    r=$(get_ticket_rank "$f")
    [[ "$r" -eq "$new_rank" ]] && { other_file="$f"; break; }
  done

  if [[ -z "$other_file" ]]; then
    echo "Error: could not find ticket at rank $new_rank" >&2
    exit 1
  fi

  set_ticket_rank "$target_file" "$new_rank"
  set_ticket_rank "$other_file" "$target_rank"
  echo "Demoted $ticket_code to rank $new_rank."
}

cmd_rank_first() {
  check_dependencies
  local tickets_dir="_tickets"
  local ticket_code=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--ticket)
        [[ -z "${2:-}" ]] && { echo "Error: --ticket requires a ticket code" >&2; exit 1; }
        ticket_code="$2"
        shift
        ;;
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        rank_first_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        rank_first_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$ticket_code" ]]; then
    echo "Error: --ticket is required" >&2
    rank_first_usage
    exit 1
  fi

  normalize_ranks "$tickets_dir"

  local target_file
  target_file=$(find_ticket_by_code "$tickets_dir" "$ticket_code")
  if [[ -z "$target_file" ]]; then
    echo "Error: no ticket found for code '$ticket_code'" >&2
    exit 1
  fi

  local target_rank
  target_rank=$(get_ticket_rank "$target_file")

  if [[ "$target_rank" -eq 1 ]]; then
    echo "Ticket $ticket_code is already at the highest priority."
    return 0
  fi

  for f in "$tickets_dir"/*.md; do
    [[ "$f" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$f" ]] || continue
    local r
    r=$(get_ticket_rank "$f")
    if [[ "$r" =~ ^[0-9]+$ && "$r" -ge 1 && "$r" -lt "$target_rank" ]]; then
      set_ticket_rank "$f" $((r + 1))
    fi
  done

  set_ticket_rank "$target_file" 1
  echo "Moved $ticket_code to rank 1."
}

cmd_rank_last() {
  check_dependencies
  local tickets_dir="_tickets"
  local ticket_code=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--ticket)
        [[ -z "${2:-}" ]] && { echo "Error: --ticket requires a ticket code" >&2; exit 1; }
        ticket_code="$2"
        shift
        ;;
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        rank_last_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        rank_last_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$ticket_code" ]]; then
    echo "Error: --ticket is required" >&2
    rank_last_usage
    exit 1
  fi

  normalize_ranks "$tickets_dir"

  local target_file
  target_file=$(find_ticket_by_code "$tickets_dir" "$ticket_code")
  if [[ -z "$target_file" ]]; then
    echo "Error: no ticket found for code '$ticket_code'" >&2
    exit 1
  fi

  local target_rank
  target_rank=$(get_ticket_rank "$target_file")

  local max_rank=0
  for f in "$tickets_dir"/*.md; do
    [[ "$f" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$f" ]] || continue
    local r
    r=$(get_ticket_rank "$f")
    [[ "$r" =~ ^[0-9]+$ && "$r" -gt "$max_rank" ]] && max_rank="$r"
  done

  if [[ "$target_rank" -eq "$max_rank" ]]; then
    echo "Ticket $ticket_code is already at the lowest priority."
    return 0
  fi

  for f in "$tickets_dir"/*.md; do
    [[ "$f" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$f" ]] || continue
    local r
    r=$(get_ticket_rank "$f")
    if [[ "$r" =~ ^[0-9]+$ && "$r" -gt "$target_rank" ]]; then
      set_ticket_rank "$f" $((r - 1))
    fi
  done

  set_ticket_rank "$target_file" "$max_rank"
  echo "Moved $ticket_code to rank $max_rank."
}

cmd_rank() {
  check_dependencies
  local tickets_dir="_tickets"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        rank_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets rank --help' for usage." >&2
        exit 1
        ;;
    esac
    shift
  done

  normalize_ranks "$tickets_dir"
}

cmd_list() {
  check_dependencies
  local tickets_dir="_tickets"
  local filter=""
  local limit=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -g|--group)
         [[ -z "${2:-}" ]] && { echo "Error: -g/--group requires a value (backlog, active, done, or todo)" >&2; exit 1; }
        [[ -n "$filter" ]] && { echo "Error: only one filter option may be specified" >&2; exit 1; }
        group_val_lower=$(echo "$2" | tr '[:upper:]' '[:lower:]')
        known=(backlog active done todo)
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
        known=(backlog ready inprogress complete duplicate wontfix)
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
            echo "Error: invalid status '$2'. Valid statuses: backlog, ready, inprogress, complete, duplicate, wontfix" >&2
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
      -l|--limit)
        [[ -z "${2:-}" ]] && { echo "Error: -l/--limit requires a positive integer argument" >&2; exit 1; }
        [[ "$2" =~ ^[1-9][0-9]*$ ]] || { echo "Error: -l/--limit must be a positive integer (>= 1), got '$2'" >&2; exit 1; }
        limit="$2"
        shift
        ;;
      *)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets list --help' for usage." >&2
        exit 1
        ;;
    esac
    shift
  done

  local cols
  cols=$(tput cols 2>/dev/null) || cols="${COLUMNS:-80}"

  local code_width=8
  local rank_width=5
  local status_width=12
  local num_columns=4
  local subject_width=$(( cols - code_width - rank_width - status_width - (num_columns - 1) ))
  [[ $subject_width -lt 10 ]] && subject_width=10

  local total=0
  local all_total=0
  local tmpfile
  tmpfile=$(mktemp)
  local shown_tmpfile
  shown_tmpfile=$(mktemp)

  for ticket in "$tickets_dir"/*.md; do
    [[ "$ticket" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$ticket" ]] || continue

    all_total=$((all_total + 1))

    filename=$(basename "$ticket")
    number="${filename%% *}"

    subject=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket" .name)
    [[ ${#subject} -gt $subject_width ]] && subject="${subject:0:$((subject_width - 3))}..."
    status=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket" .ticket_status | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')

    case "$filter" in
      backlog) [[ "$status" != "Backlog" ]] && continue ;;
      active)  [[ "$status" != "Ready" && "$status" != "In Progress" ]] && continue ;;
      todo)    [[ "$status" != "Backlog" && "$status" != "Ready" && "$status" != "In Progress" ]] && continue ;;
      done)    [[ "$status" != "Complete" && "$status" != "Duplicate" && "$status" != "Won't Fix" ]] && continue ;;
      status:*)
        expected="${filter#status:}"
        status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        [[ "$status_lower" != "$expected" ]] && continue
        ;;
    esac

    total=$((total + 1))

    local rank_val
    rank_val=$(get_ticket_rank "$ticket")
    if [[ ! "$rank_val" =~ ^[0-9]+$ ]]; then
      rank_val=999999
    fi

    printf '%s\t%s\t%s\t%s\n' "$rank_val" "$number" "$subject" "$status" >> "$tmpfile"
  done

  printf "%-${code_width}s %-${subject_width}s %${rank_width}s %-${status_width}s\n" "Code" "Subject" "Rank" "Status"

  local code_dashes subject_dashes rank_dashes status_dashes
  code_dashes=$(printf '%*s' "$code_width" '' | tr ' ' '-')
  subject_dashes=$(printf '%*s' "$subject_width" '' | tr ' ' '-')
  rank_dashes=$(printf '%*s' "$rank_width" '' | tr ' ' '-')
  status_dashes=$(printf '%*s' "$status_width" '' | tr ' ' '-')
  printf "%-${code_width}s %-${subject_width}s %${rank_width}s %-${status_width}s\n" \
    "$code_dashes" "$subject_dashes" "$rank_dashes" "$status_dashes"

  sort -t$'\t' -k1 -n "$tmpfile" | head -n "${limit:-999999}" | tee "$shown_tmpfile" | while IFS=$'\t' read -r rank_val number subject status; do
    local display_rank="$rank_val"
    case "$status" in
      Complete|Duplicate|"Won't Fix") display_rank="-" ;;
    esac
    printf "%-${code_width}s %-${subject_width}s %${rank_width}s %-${status_width}s\n" "$number" "$subject" "$display_rank" "$status"
  done

  printf "%-${code_width}s %-${subject_width}s %${rank_width}s %-${status_width}s\n" \
    "$code_dashes" "$subject_dashes" "$rank_dashes" "$status_dashes"

  local shown
  shown=$(wc -l < "$shown_tmpfile")
  local limit_note=""
  if [[ -n "$limit" && "$total" -gt "$limit" ]]; then
    limit_note=" (limited to $limit)"
  fi
  echo "$total matching from $all_total total tickets$limit_note"

  rm -f "$tmpfile" "$shown_tmpfile"
}

cmd_create() {
  check_dependencies
  local tickets_dir="_tickets"
  local ticket_name=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--name)
        [[ -z "${2:-}" ]] && { echo "Error: --name requires a subject argument" >&2; exit 1; }
        ticket_name="$2"
        shift
        ;;
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        create_usage
        return 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets create --help' for usage." >&2
        exit 1
        ;;
      *)
        echo "Error: unexpected argument '$1'" >&2
        create_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$ticket_name" ]]; then
    echo "Error: --name is required" >&2
    create_usage
    exit 1
  fi

  local template_file="$SCRIPT_DIR/Ticket.md"
  if [[ ! -f "$template_file" ]]; then
    echo "Error: template not found alongside tickets.sh ($template_file)" >&2
    exit 1
  fi

  local resolved_dir
  if [[ "$tickets_dir" == /* ]]; then
    resolved_dir="$tickets_dir"
  else
    resolved_dir="$(pwd)/$tickets_dir"
  fi

  local settings_file="$resolved_dir/settings.yaml"
  local code_prefix
  if [[ -f "$settings_file" ]]; then
    code_prefix=$(python3 "$SCRIPT_DIR/yz.py" read "$settings_file" .code_prefix)
  else
    echo "Error: $resolved_dir/settings.yaml not found" >&2
    exit 1
  fi

  if [[ -z "$code_prefix" ]]; then
    echo "Error: code_prefix not set in $resolved_dir/settings.yaml" >&2
    exit 1
  fi

  local max_num=0
  for ticket_file in "$resolved_dir"/*.md; do
    [[ -f "$ticket_file" ]] || continue
    local filename
    filename=$(basename "$ticket_file")
    if [[ "$filename" =~ ^${code_prefix}([0-9]{3}) ]]; then
      local num
      num=$((10#${BASH_REMATCH[1]}))
      [[ $num -gt $max_num ]] && max_num=$num
    fi
  done

  local max_rank=0
  for ticket_file in "$resolved_dir"/*.md; do
    [[ -f "$ticket_file" ]] || continue
    local r
    r=$(get_ticket_rank "$ticket_file")
    [[ "$r" =~ ^[0-9]+$ && "$r" -gt "$max_rank" ]] && max_rank="$r"
  done
  local next_rank=$((max_rank + 1))

  local next_num=$((max_num + 1))
  local next_code
  next_code=$(printf "%s%03d" "$code_prefix" "$next_num")

  if ls "$resolved_dir/${next_code}"* &>/dev/null 2>&1; then
    echo "Error: ticket with code '$next_code' already exists" >&2
    exit 1
  fi

  local output_file="$resolved_dir/${next_code} - ${ticket_name}.md"

  local template_body
  template_body=$(awk '/^---$/{c++; next} c>=2' "$template_file")

  {
    printf '%s\n' "---"
    printf '%s\n' 'template: "[[Ticket]]"'
    printf '%s\n' "kind: ticket"
    printf '%s\n' "tags:"
    printf '%s\n' "  - ticket"
    printf '%s\n' "code: $next_code"
    printf '%s\n' "aliases:"
    printf '%s\n' "  - $next_code"
    printf '%s\n' "name: $ticket_name"
    printf '%s\n' 'ticket_status: "[[Backlog]]"'
    printf '%s\n' "ticket_priority: Medium"
    printf '%s\n' "ticket_rank: $next_rank"
    local created_ts
    created_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    printf '%s\n' "ticket_created: $created_ts"
    printf '%s\n' "ticket_updated: $created_ts"
    printf '%s\n' "ticket_completed:"
    printf '%s\n' "---"
    printf '%s' "$template_body"
  } > "$output_file"

  echo "Created: $output_file"
}

cmd_init() {
  local tickets_dir="_tickets"
  local code_prefix=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      --code-prefix)
        [[ -z "${2:-}" ]] && { echo "Error: --code-prefix requires a value" >&2; exit 1; }
        code_prefix="$2"
        shift
        ;;
      -h|--help)
        init_usage
        return 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets init --help' for usage." >&2
        exit 1
        ;;
      *)
        echo "Error: unexpected argument '$1'" >&2
        init_usage
        exit 1
        ;;
    esac
    shift
  done

  local settings_file="$tickets_dir/settings.yaml"
  if [[ -f "$settings_file" ]]; then
    echo "Error: tickets directory has already been initialized ($settings_file exists)" >&2
    exit 1
  fi

  if [[ -n "$code_prefix" ]]; then
    if [[ ! "$code_prefix" =~ ^[A-Za-z]{3,4}$ ]]; then
      echo "Error: --code-prefix must be 3 or 4 alphabetic characters" >&2
      exit 1
    fi
    code_prefix=$(echo "$code_prefix" | tr '[:lower:]' '[:upper:]')
  else
    while true; do
      printf "Enter ticket code prefix (3-4 alphabetic characters): "
      read -r code_prefix
      if [[ "$code_prefix" =~ ^[A-Za-z]{3,4}$ ]]; then
        code_prefix=$(echo "$code_prefix" | tr '[:lower:]' '[:upper:]')
        break
      fi
      echo "Invalid prefix. Must be 3 or 4 alphabetic characters." >&2
    done
  fi

  mkdir -p "$tickets_dir"
  echo "Created: $tickets_dir/"

  echo "code_prefix: $code_prefix" > "$settings_file"
  echo "Created: $settings_file"

  local stats_file="$tickets_dir/statistics.yaml"
  if [[ ! -f "$stats_file" ]]; then
    echo "statistics: []" > "$stats_file"
    echo "Created: $stats_file"
  fi

}

cmd_validate() {
  local tickets_dir="_tickets"
  local mode=""       # "all" or "single"
  local ticket_code=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -a|--all)
        [[ -n "$mode" ]] && { echo "Error: --all and --ticket are mutually exclusive" >&2; exit 1; }
        mode="all"
        ;;
      -t|--ticket)
        [[ -z "${2:-}" ]] && { echo "Error: --ticket requires a ticket code" >&2; exit 1; }
        [[ -n "$mode" ]] && { echo "Error: --all and --ticket are mutually exclusive" >&2; exit 1; }
        mode="single"
        ticket_code="$2"
        shift
        ;;
      -h|--help)
        validate_usage
        return 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets validate --help' for usage." >&2
        exit 1
        ;;
      *)
        # Backward compat: positional ticket code
        if [[ -z "$mode" ]]; then
          mode="single"
          ticket_code="$1"
        else
          echo "Error: unexpected argument '$1'" >&2
          validate_usage
          exit 1
        fi
        ;;
    esac
    shift
  done

  if [[ -z "$mode" ]]; then
    echo "Error: --all or --ticket is required" >&2
    validate_usage
    exit 1
  fi

  # Check dependencies (python3 + pyyaml)
  check_dependencies

  local template_file="$SCRIPT_DIR/Ticket.md"
  if [[ ! -f "$template_file" ]]; then
    echo "Error: template not found alongside tickets.sh ($template_file)" >&2
    exit 1
  fi

  local settings_file="$tickets_dir/settings.yaml"
  local code_prefix
  if [[ -f "$settings_file" ]]; then
    code_prefix=$(python3 "$SCRIPT_DIR/yz.py" read "$settings_file" .code_prefix TIK 2>/dev/null) || code_prefix="TIK"
  else
    code_prefix="TIK"
  fi

  local total_errors=0
  local ticket_count=0

  if [[ "$mode" == "all" ]]; then
    local total_tickets=0
    for ticket_file in "$tickets_dir"/*.md; do
      [[ "$ticket_file" == "$tickets_dir/*.md" ]] && break
      [[ -f "$ticket_file" ]] || continue
      filename=$(basename "$ticket_file")
      number="${filename%% *}"
      total_tickets=$((total_tickets + 1))
      set +e
      validate_one "$ticket_file" "$template_file" "$code_prefix" "$number"
      total_errors=$((total_errors + $?))
      set -e
      ticket_count=$((ticket_count + 1))
    done
    if [[ $total_tickets -eq 0 ]]; then
      echo "Error: no tickets found in $tickets_dir" >&2
      exit 1
    fi
  else
    local matches=()
    for f in "$tickets_dir"/"$ticket_code"*.md; do
      [[ "$f" == "$tickets_dir/$ticket_code*.md" ]] && break
      [[ -f "$f" ]] && matches+=("$f")
    done
    if [[ ${#matches[@]} -eq 0 ]]; then
      echo "Error: no ticket found for code '$ticket_code'" >&2
      exit 1
    elif [[ ${#matches[@]} -gt 1 ]]; then
      echo "Error: multiple tickets match code '$ticket_code': ${matches[*]}" >&2
      exit 1
    fi
    local ticket_file="${matches[0]}"
    filename=$(basename "$ticket_file")
    number="${filename%% *}"
    set +e
    validate_one "$ticket_file" "$template_file" "$code_prefix" "$number"
    total_errors=$?
    set -e
    ticket_count=1
  fi

  if [[ $total_errors -eq 0 ]]; then
    if [[ "$mode" == "all" ]]; then
      echo "$ticket_count ticket(s) validated, no deviations found."
    fi
    return 0
  else
    return 1
  fi
}

validate_one() {
  local ticket_file="$1"
  local template_file="$2"
  local code_prefix="$3"
  local ticket_code="$4"
  local errors=0

  echo "Validating: $ticket_file" >&2

  # Extract template keys
  local template_keys
  template_keys=$(python3 "$SCRIPT_DIR/yz.py" keys "$template_file" 2>/dev/null || true)

  # Extract ticket keys
  local ticket_keys
  ticket_keys=$(python3 "$SCRIPT_DIR/yz.py" keys "$ticket_file" 2>/dev/null || true)

  # Missing fields (in template but not in ticket)
  while IFS= read -r tkey; do
    [[ -z "$tkey" ]] && continue
    # ticket_updated is optional — existing tickets may not have it yet
    [[ "$tkey" == "ticket_updated" ]] && continue
    if ! echo "$ticket_keys" | grep -Fxq "$tkey"; then
      echo "- Missing required field: $tkey" >&2
      errors=$((errors + 1))
    fi
  done <<< "$template_keys"

  # Unknown fields (in ticket but not in template)
  while IFS= read -r tkey; do
    [[ -z "$tkey" ]] && continue
    if ! echo "$template_keys" | grep -Fxq "$tkey"; then
      echo "- Unknown field: $tkey" >&2
      errors=$((errors + 1))
    fi
  done <<< "$ticket_keys"

  # Value constraint validations (hardcoded)
  local val

  # template must be [[Ticket]]
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .template 2>/dev/null || true)
  if [[ "$val" != "[[Ticket]]" ]]; then
    echo "- Invalid value for template: expected '[[Ticket]]', got '$val'" >&2
    errors=$((errors + 1))
  fi

  # kind must be ticket
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .kind 2>/dev/null || true)
  if [[ "$val" != "ticket" ]]; then
    echo "- Invalid value for kind: expected 'ticket', got '$val'" >&2
    errors=$((errors + 1))
  fi

  # code must match <prefix>\d{3}
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .code 2>/dev/null || true)
  if ! [[ "$val" =~ ^${code_prefix}[0-9]{3}$ ]]; then
    echo "- Invalid value for code: expected pattern '${code_prefix}\\d{3}', got '$val'" >&2
    errors=$((errors + 1))
  fi

  # name must be non-empty
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .name 2>/dev/null || true)
  if [[ -z "$val" ]]; then
    echo "- Invalid value for name: must be non-empty" >&2
    errors=$((errors + 1))
  fi

  # aliases must contain exactly one entry matching code
  local ticket_code_val
  ticket_code_val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .code 2>/dev/null || true)
  local alias_count
  alias_count=$(python3 "$SCRIPT_DIR/yz.py" len "$ticket_file" .aliases 2>/dev/null || true)
  if [[ "$alias_count" != "1" ]]; then
    echo "- Invalid value for aliases: expected exactly 1 entry, got $alias_count" >&2
    errors=$((errors + 1))
  else
    val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .aliases[0] 2>/dev/null || true)
    if [[ "$val" != "$ticket_code_val" ]]; then
      echo "- Invalid value for aliases: expected '$ticket_code_val', got '$val'" >&2
      errors=$((errors + 1))
    fi
  fi

  # ticket_status must be one of the six known statuses
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_status 2>/dev/null || true)
  local valid_statuses=("[[Backlog]]" "[[Ready]]" "[[In Progress]]" "[[Complete]]" "[[Duplicate]]" "[[Won't Fix]]")
  local status_ok=0
  for s in "${valid_statuses[@]}"; do
    if [[ "$val" == "$s" ]]; then
      status_ok=1
      break
    fi
  done
  if [[ $status_ok -eq 0 ]]; then
    echo "- Invalid value for ticket_status: got '$val'" >&2
    errors=$((errors + 1))
  fi

  # ticket_priority must be one of Low, Medium, High, Critical
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_priority 2>/dev/null || true)
  local valid_priorities=("Low" "Medium" "High" "Critical")
  local pri_ok=0
  for p in "${valid_priorities[@]}"; do
    if [[ "$val" == "$p" ]]; then
      pri_ok=1
      break
    fi
  done
  if [[ $pri_ok -eq 0 ]]; then
    echo "- Invalid value for ticket_priority: got '$val'" >&2
    errors=$((errors + 1))
  fi

  # ticket_rank must be present and hold an integer value, unless done
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_rank 2>/dev/null || true)
  local status_val
  status_val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_status 2>/dev/null || true)
  local is_done=0
  case "$status_val" in
    "[[Complete]]"|"[[Duplicate]]"|"[[Won't Fix]]") is_done=1 ;;
  esac
  if [[ -z "$val" ]]; then
    if [[ $is_done -eq 0 ]]; then
      echo "- Invalid value for ticket_rank: must be present and hold an integer" >&2
      errors=$((errors + 1))
    fi
  elif [[ ! "$val" =~ ^[0-9]+$ ]]; then
    echo "- Invalid value for ticket_rank: expected an integer, got '$val'" >&2
    errors=$((errors + 1))
  fi

  # ticket_created: if present must be ISO 8601 UTC (Z suffix)
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_created 2>/dev/null || true)
  if [[ -n "$val" ]] && ! [[ "$val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
    echo "- Invalid value for ticket_created: expected ISO 8601 UTC (e.g. 2026-06-13T14:30:00Z), got '$val'" >&2
    errors=$((errors + 1))
  fi

  # ticket_updated: if present must be ISO 8601 UTC (Z suffix)
  val=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_updated 2>/dev/null || true)
  if [[ -n "$val" ]] && ! [[ "$val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
    echo "- Invalid value for ticket_updated: expected ISO 8601 UTC (e.g. 2026-06-13T14:30:00Z), got '$val'" >&2
    errors=$((errors + 1))
  fi

  return $errors
}

cmd_transition() {
  check_dependencies
  local tickets_dir="_tickets"
  local ticket_code=""
  local target_status=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t|--ticket)
        [[ -z "${2:-}" ]] && { echo "Error: --ticket requires a ticket code" >&2; exit 1; }
        ticket_code="$2"
        shift
        ;;
      -T|--target)
        [[ -z "${2:-}" ]] && { echo "Error: --target requires a status value" >&2; exit 1; }
        target_status="$2"
        shift
        ;;
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        transition_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets transition --help' for usage." >&2
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$ticket_code" ]]; then
    echo "Error: --ticket is required" >&2
    transition_usage
    exit 1
  fi

  if [[ -z "$target_status" ]]; then
    echo "Error: --target is required" >&2
    transition_usage
    exit 1
  fi

  local target_lower
  target_lower=$(echo "$target_status" | tr '[:upper:]' '[:lower:]')
  local known=(backlog ready inprogress complete duplicate wontfix)
  local target_canonical=""
  for k in "${known[@]}"; do
    if [[ "$k" == "$target_lower" ]]; then
      target_canonical="$k"
      break
    fi
  done
  if [[ -z "$target_canonical" ]]; then
    local matches=()
    for k in "${known[@]}"; do
      [[ "$k" == *"$target_lower"* ]] && matches+=("$k")
    done
    if [[ ${#matches[@]} -eq 1 ]]; then
      target_canonical="${matches[0]}"
    elif [[ ${#matches[@]} -eq 0 ]]; then
      echo "Error: invalid status '$target_status'. Valid statuses: backlog, ready, inprogress, complete, duplicate, wontfix" >&2
      exit 1
    else
      echo "Error: ambiguous status '$target_status'. Matches: ${matches[*]}" >&2
      exit 1
    fi
  fi

  local ticket_file
  ticket_file=$(find_ticket_by_code "$tickets_dir" "$ticket_code") || true
  if [[ -z "$ticket_file" ]]; then
    echo "Error: no ticket found for code '$ticket_code'" >&2
    exit 1
  fi

  local current_status
  current_status=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket_file" .ticket_status | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')
  local current_lower
  current_lower=$(echo "$current_status" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

  if [[ "$current_lower" == "$target_canonical" ]]; then
    echo "Ticket $ticket_code is already in status '$current_status'."
    return 0
  fi

  local status_label
  case "$target_canonical" in
    backlog)    status_label="[[Backlog]]" ;;
    ready)      status_label="[[Ready]]" ;;
    inprogress) status_label="[[In Progress]]" ;;
    complete)   status_label="[[Complete]]" ;;
    duplicate)  status_label="[[Duplicate]]" ;;
    wontfix)    status_label="[[Won't Fix]]" ;;
  esac

  case "$target_canonical" in
    complete|duplicate|wontfix)
      python3 "$SCRIPT_DIR/yz.py" update "$ticket_file" .ticket_rank null
      sed -i 's/^ticket_rank: null$/ticket_rank:/' "$ticket_file"
      local ts
      ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      TS="$ts" python3 "$SCRIPT_DIR/yz.py" set-env "$ticket_file" .ticket_completed TS
      ;;
    backlog|ready|inprogress)
      python3 "$SCRIPT_DIR/yz.py" delete "$ticket_file" .ticket_completed
      ;;
  esac

  case "$current_status" in
    "Complete"|"Duplicate"|"Won't Fix")
      local current_rank
      current_rank=$(get_ticket_rank "$ticket_file")
      if [[ -z "$current_rank" || ! "$current_rank" =~ ^[0-9]+$ ]]; then
        local max_rank=0
        for f in "$tickets_dir"/*.md; do
          [[ -f "$f" ]] || continue
          local r
          r=$(get_ticket_rank "$f")
          [[ "$r" =~ ^[0-9]+$ && "$r" -gt "$max_rank" ]] && max_rank="$r"
        done
        set_ticket_rank "$ticket_file" $((max_rank + 1))
      fi
      ;;
  esac

  python3 "$SCRIPT_DIR/yz.py" update "$ticket_file" .ticket_status "$status_label"

  case "$target_canonical" in
    complete|duplicate|wontfix)
      normalize_ranks "$tickets_dir" >/dev/null
      ;;
  esac

  touch_ticket_updated "$ticket_file"

  echo "Transitioned $ticket_code to '$target_canonical'."
}

cmd_statistics_snapshot() {
  check_dependencies
  local tickets_dir="_tickets"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--tickets-dir)
        [[ -z "${2:-}" ]] && { echo "Error: --tickets-dir requires a path argument" >&2; exit 1; }
        tickets_dir="$2"
        shift
        ;;
      -h|--help)
        statistics_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets statistics snapshot --help' for usage." >&2
        exit 1
        ;;
    esac
    shift
  done

  if [[ ! -d "$tickets_dir" ]]; then
    echo "Error: tickets directory '$tickets_dir' does not exist" >&2
    exit 1
  fi

  local stats_file="$tickets_dir/statistics.yaml"

  local total=0
  local backlog=0
  local ready=0
  local inprogress=0
  local complete=0
  local duplicate=0
  local wontfix=0

  for ticket in "$tickets_dir"/*.md; do
    [[ "$ticket" == "$tickets_dir/*.md" ]] && break
    [[ -f "$ticket" ]] || continue
    [[ "$(basename "$ticket")" == ".gitkeep" ]] && continue

    total=$((total + 1))

    local status
    status=$(python3 "$SCRIPT_DIR/yz.py" extract "$ticket" .ticket_status 2>/dev/null || echo "")
    status=$(echo "$status" | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')

    case "$status" in
      Backlog)     backlog=$((backlog + 1)) ;;
      Ready)       ready=$((ready + 1)) ;;
      "In Progress") inprogress=$((inprogress + 1)) ;;
      Complete)    complete=$((complete + 1)) ;;
      Duplicate)   duplicate=$((duplicate + 1)) ;;
      "Won't Fix") wontfix=$((wontfix + 1)) ;;
    esac
  done

  local todo=$((backlog + ready + inprogress))
  local done=$((complete + duplicate + wontfix))

  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "ts: $ts"
  echo "total: $total"
  echo "status:"
  echo "  backlog: $backlog"
  echo "  ready: $ready"
  echo "  inprogress: $inprogress"
  echo "  complete: $complete"
  echo "  duplicate: $duplicate"
  echo "  wontfix: $wontfix"
  echo "groups:"
  echo "  todo: $todo"
  echo "  done: $done"

  if [[ ! -f "$stats_file" ]]; then
    echo "statistics: []" > "$stats_file"
  fi

  local snapshot_json
  snapshot_json=$(printf '{"ts":"%s","total":%d,"status":{"backlog":%d,"ready":%d,"inprogress":%d,"complete":%d,"duplicate":%d,"wontfix":%d},"groups":{"todo":%d,"done":%d}}' \
    "$ts" "$total" "$backlog" "$ready" "$inprogress" "$complete" "$duplicate" "$wontfix" "$todo" "$done")
  python3 "$SCRIPT_DIR/yz.py" append "$stats_file" .statistics "$snapshot_json"
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
  validate)
    cmd_validate "$@"
    ;;
  create)
    cmd_create "$@"
    ;;
  transition)
    cmd_transition "$@"
    ;;
  rank)
    case "${1:-}" in
      up)
        shift
        cmd_rank_up "$@"
        ;;
      down)
        shift
        cmd_rank_down "$@"
        ;;
      first)
        shift
        cmd_rank_first "$@"
        ;;
      last)
        shift
        cmd_rank_last "$@"
        ;;
      *)
        cmd_rank "$@"
        ;;
    esac
    ;;
  statistics)
    case "${1:-}" in
      snapshot)
        shift
        cmd_statistics_snapshot "$@"
        ;;
      *)
        statistics_usage
        ;;
    esac
    ;;
  init)
    cmd_init "$@"
    ;;
  *)
    echo "Unknown subcommand: $subcommand" >&2
    usage
    exit 1
    ;;
esac
