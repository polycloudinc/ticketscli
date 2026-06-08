#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_NAME=$(cat "$SCRIPT_DIR/name")

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux kill-session -t "$SESSION_NAME"
    echo "Session '$SESSION_NAME' has been closed."
else
    echo "Session '$SESSION_NAME' does not exist."
fi
