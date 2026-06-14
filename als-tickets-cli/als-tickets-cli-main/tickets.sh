#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: tickets <subcommand> [options]

Subcommands:
  list              List tickets from the tickets directory
  validate          Validate a ticket's front matter against the schema
  create            Create a new ticket file
  rank              Normalize ticket ranks across all tickets
  rank up           Promote a ticket's priority
  rank down         Demote a ticket's priority
  rank first        Move a ticket to rank 1
  rank last         Move a ticket to the lowest rank

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
  -g, --group <backlog|active|done>  Filter tickets by status group
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

normalize_ranks() {
  local tickets_dir="$1"
  local tmpfile
  tmpfile=$(mktemp)

  for ticket in "$tickets_dir"/*.md; do
    [[ "$ticket" == "$tickets_dir/.gitkeep" ]] && continue
    [[ -f "$ticket" ]] || continue

    local status
    status=$(sed -n '/^---$/,/^---$/p' "$ticket" | grep '^ticket_status:' | sed 's/^ticket_status: *//' | tr -d '"' | sed 's/^\[\[//; s/\]\]$//')

    case "$status" in
      "Complete"|"Duplicate"|"Won't Fix")
        sed -i "/^ticket_rank:/ s/:.*/: /" "$ticket"
        continue
        ;;
    esac

    local rank_val
    rank_val=$(sed -n '/^---$/,/^---$/p' "$ticket" | grep '^ticket_rank:' | sed 's/^ticket_rank: *//')

    if [[ "$rank_val" =~ ^[0-9]+$ ]]; then
      printf '%d\t%s\n' "$rank_val" "$ticket" >> "$tmpfile"
    else
      printf '%d\t%s\n' 999999 "$ticket" >> "$tmpfile"
    fi
  done

  local new_rank=1
  local count=0
  while IFS=$'\t' read -r _ ticket_file; do
    sed -i "/^ticket_rank:/ s/: .*/: $new_rank/" "$ticket_file"
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
  sed -n '/^---$/,/^---$/p' "$ticket_file" | grep '^ticket_rank:' | sed 's/^ticket_rank: *//'
}

set_ticket_rank() {
  local ticket_file="$1"
  local new_rank="$2"
  sed -i "/^ticket_rank:/ s/: .*/: $new_rank/" "$ticket_file"
}

cmd_rank_up() {
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
  local tickets_dir="_tickets"
  local filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--tickets-dir)
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
      *)
        echo "Unknown option: $1" >&2
        echo "Run 'tickets list --help' for usage." >&2
        exit 1
        ;;
    esac
    shift
  done

  local tmpfile
  tmpfile=$(mktemp)

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
        status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        [[ "$status_lower" != "$expected" ]] && continue
        ;;
    esac

    local rank_val
    rank_val=$(echo "$frontmatter" | grep '^ticket_rank:' | sed 's/^ticket_rank: *//')
    if [[ ! "$rank_val" =~ ^[0-9]+$ ]]; then
      rank_val=999999
    fi

    printf '%s\t%s\t%s\t%s\n' "$rank_val" "$number" "$subject" "$status" >> "$tmpfile"
  done

  printf "%-8s %-47s %6s %-12s\n" "Code" "Subject" "Rank" "Status"
  printf "%-8s %-47s %6s %-12s\n" "----" "-------" "----" "------"

  sort -t$'\t' -k1 -n "$tmpfile" | while IFS=$'\t' read -r rank_val number subject status; do
    local display_rank="$rank_val"
    case "$status" in
      Complete|Duplicate|"Won't Fix") display_rank="-" ;;
    esac
    printf "%-8s %-47s %6s %-12s\n" "$number" "$subject" "$display_rank" "$status"
  done

  rm -f "$tmpfile"
}

cmd_create() {
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

  local repo_root
  repo_root="$(pwd)"
  while [[ ! -f "$repo_root/_templates/Ticket.md" && "$repo_root" != "/" ]]; do
    repo_root="$(dirname "$repo_root")"
  done

  local template_file="$repo_root/_templates/Ticket.md"
  if [[ ! -f "$template_file" ]]; then
    echo "Error: template not found. Expected _templates/Ticket.md relative to the project root." >&2
    exit 1
  fi

  local resolved_dir
  if [[ "$tickets_dir" == /* ]]; then
    resolved_dir="$tickets_dir"
  else
    resolved_dir="$repo_root/$tickets_dir"
  fi

  local settings_file="$resolved_dir/settings.yaml"
  local code_prefix
  if [[ -f "$settings_file" ]]; then
    code_prefix=$(sed -n 's/^code_prefix: *//p' "$settings_file")
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
    r=$(sed -n '/^---$/,/^---$/p' "$ticket_file" | grep '^ticket_rank:' | sed 's/^ticket_rank: *//')
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
    printf '%s\n' "---"
    printf '%s' "$template_body"
  } > "$output_file"

  echo "Created: $output_file"
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

  # Check yq early
  if ! command -v yq &>/dev/null; then
    echo "Error: yq is required but not installed. Install it from https://github.com/mikefarah/yq" >&2
    exit 1
  fi

  local yq_version
  yq_version=$(yq --version 2>/dev/null || true)
  if [[ "$yq_version" != *mikefarah* ]]; then
    echo "Error: mikefarah/yq (Go) is required. Found: ${yq_version:-unknown}" >&2
    exit 1
  fi

  # Find repo root
  local repo_root
  repo_root="$(pwd)"
  while [[ ! -f "$repo_root/_templates/Ticket.md" && "$repo_root" != "/" ]]; do
    repo_root="$(dirname "$repo_root")"
  done

  local template_file="$repo_root/_templates/Ticket.md"
  if [[ ! -f "$template_file" ]]; then
    echo "Error: template not found. Expected _templates/Ticket.md relative to the project root." >&2
    exit 1
  fi

  local settings_file="$repo_root/$tickets_dir/settings.yaml"
  local code_prefix
  if [[ -f "$settings_file" ]]; then
    code_prefix=$(yq eval '.code_prefix // "TIK"' "$settings_file" 2>/dev/null) || code_prefix="TIK"
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
  template_keys=$(yq eval --front-matter extract 'keys | .[]' "$template_file" 2>/dev/null || true)

  # Extract ticket keys
  local ticket_keys
  ticket_keys=$(yq eval --front-matter extract 'keys | .[]' "$ticket_file" 2>/dev/null || true)

  # Missing fields (in template but not in ticket)
  while IFS= read -r tkey; do
    [[ -z "$tkey" ]] && continue
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
  val=$(yq eval --front-matter extract '.template // ""' "$ticket_file" 2>/dev/null || true)
  if [[ "$val" != "[[Ticket]]" ]]; then
    echo "- Invalid value for template: expected '[[Ticket]]', got '$val'" >&2
    errors=$((errors + 1))
  fi

  # kind must be ticket
  val=$(yq eval --front-matter extract '.kind // ""' "$ticket_file" 2>/dev/null || true)
  if [[ "$val" != "ticket" ]]; then
    echo "- Invalid value for kind: expected 'ticket', got '$val'" >&2
    errors=$((errors + 1))
  fi

  # code must match <prefix>\d{3}
val=$(yq eval --front-matter extract '.code // ""' "$ticket_file" 2>/dev/null || true)
  if ! [[ "$val" =~ ^${code_prefix}[0-9]{3}$ ]]; then
    echo "- Invalid value for code: expected pattern '${code_prefix}\\d{3}', got '$val'" >&2
    errors=$((errors + 1))
  fi

  # name must be non-empty
  val=$(yq eval --front-matter extract '.name // ""' "$ticket_file" 2>/dev/null || true)
  if [[ -z "$val" ]]; then
    echo "- Invalid value for name: must be non-empty" >&2
    errors=$((errors + 1))
  fi

  # aliases must contain exactly one entry matching code
  local ticket_code_val
  ticket_code_val=$(yq eval --front-matter extract '.code // ""' "$ticket_file" 2>/dev/null || true)
  local alias_count
  alias_count=$(yq eval --front-matter extract '.aliases | length' "$ticket_file" 2>/dev/null || true)
  if [[ "$alias_count" != "1" ]]; then
    echo "- Invalid value for aliases: expected exactly 1 entry, got $alias_count" >&2
    errors=$((errors + 1))
  else
    val=$(yq eval --front-matter extract '.aliases[0] // ""' "$ticket_file" 2>/dev/null || true)
    if [[ "$val" != "$ticket_code_val" ]]; then
      echo "- Invalid value for aliases: expected '$ticket_code_val', got '$val'" >&2
      errors=$((errors + 1))
    fi
  fi

  # ticket_status must be one of the six known statuses
  val=$(yq eval --front-matter extract '.ticket_status // ""' "$ticket_file" 2>/dev/null || true)
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
  val=$(yq eval --front-matter extract '.ticket_priority // ""' "$ticket_file" 2>/dev/null || true)
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
  val=$(yq eval --front-matter extract '.ticket_rank // ""' "$ticket_file" 2>/dev/null || true)
  local status_val
  status_val=$(yq eval --front-matter extract '.ticket_status // ""' "$ticket_file" 2>/dev/null || true)
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
  val=$(yq eval --front-matter extract '.ticket_created // ""' "$ticket_file" 2>/dev/null || true)
  if [[ -n "$val" ]] && ! [[ "$val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
    echo "- Invalid value for ticket_created: expected ISO 8601 UTC (e.g. 2026-06-13T14:30:00Z), got '$val'" >&2
    errors=$((errors + 1))
  fi

  return $errors
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
  *)
    echo "Unknown subcommand: $subcommand" >&2
    usage
    exit 1
    ;;
esac
