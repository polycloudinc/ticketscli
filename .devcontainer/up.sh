#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

devcontainer up --workspace-folder "$WORKSPACE_ROOT"
devcontainer exec --workspace-folder "$WORKSPACE_ROOT" /bin/bash
