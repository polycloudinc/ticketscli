#!/usr/bin/env bash
set -euo pipefail

readarray -t all_files < <(git diff --cached --name-only)
staged_tickets=()
for file in "${all_files[@]}"; do
    if [[ "$file" =~ ^.tickets/.*\.md$ ]]; then
        staged_tickets+=("$file")
    fi
done

if [ ${#staged_tickets[@]} -eq 0 ]; then
    echo "No staged ticket files found under .tickets/"
    exit 1
fi

if [ ${#staged_tickets[@]} -gt 1 ]; then
    echo "Multiple ticket files staged:"
    printf '  %s\n' "${staged_tickets[@]}"
    echo "Aborting: commit message cannot be inferred from multiple tickets."
    exit 1
fi

ticket_file="${staged_tickets[0]}"
ticket_name="$(basename "$ticket_file" .md)"

echo "Staged files:"
printf '  %s\n' "${all_files[@]}"
echo "Proposed commit message: $ticket_name"
read -r -p "Proceed with commit? [y/N] " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    git commit -m "$ticket_name"
else
    echo "Commit aborted."
    exit 1
fi
