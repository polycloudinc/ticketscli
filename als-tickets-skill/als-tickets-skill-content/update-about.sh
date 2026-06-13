#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ABOUT_FILE="$SCRIPT_DIR/SKILL-ABOUT.md"
SKILLS_DIR="$REPO_ROOT/.apm/skills"

if [[ ! -f "$ABOUT_FILE" ]]; then
  echo "Error: SKILL-ABOUT.md not found at $ABOUT_FILE" >&2
  exit 1
fi

CANONICAL=$(cat "$ABOUT_FILE")

HEADING="# About Tickets System"

# Use globstar to match nested directories
shopt -s globstar nullglob
for skill_file in "$SKILLS_DIR"/**/*.md; do

  content=$(cat "$skill_file")

  if echo "$content" | grep -q "^$HEADING$"; then
    # --- Replace existing heading + paragraph ---
    new_content=$(echo "$content" | awk -v heading="$HEADING" -v canonical="$CANONICAL" '
      BEGIN { mode = "before" }
      mode == "before" {
        if ($0 == heading) { mode = "skip"; print canonical; next }
        print
      }
      mode == "skip" {
        # Skip blank lines and paragraph lines until we hit a boundary.
        if ($0 ~ /^(# |\*\*)/) {
          printf "\n%s\n", $0
          mode = "after"
          next
        }
      }
      mode == "after" { print }
    ')
    echo "$new_content" > "$skill_file"
    echo "Updated: $skill_file (replaced existing About section)"

  else
    # --- Insert after frontmatter ---
    new_content=$(echo "$content" | awk -v canonical="$CANONICAL" '
      BEGIN { dashes=0; inserted=0 }
      {
        print
        if (!inserted && $0 == "---") {
          dashes++
          if (dashes == 2) {
            printf "\n%s\n", canonical
            inserted=1
          }
        }
      }
    ')
    echo "$new_content" > "$skill_file"
    echo "Updated: $skill_file (inserted About section)"
  fi
done
