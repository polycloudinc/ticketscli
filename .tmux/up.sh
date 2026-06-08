#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_NAME=$(cat "$SCRIPT_DIR/name")
if [ -f "$SCRIPT_DIR/../product.yaml" ] && command -v yq >/dev/null 2>&1; then
    SYMBOL=$(yq -r '.symbol // empty' "$SCRIPT_DIR/../product.yaml" 2>/dev/null)
    if [ -n "$SYMBOL" ]; then
        SESSION_NAME="$SYMBOL"
    fi
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Create new session with three vertical panes
tmux new-session -d -s "$SESSION_NAME"

# Split vertically to create two panes (top and bottom)
tmux split-window -v -t "$SESSION_NAME:0.0"

# Select even-vertical layout to make all panes equal height
tmux select-layout -t "$SESSION_NAME:0" even-vertical

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
