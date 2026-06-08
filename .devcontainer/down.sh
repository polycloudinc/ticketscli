#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTAINER_ID=$(docker ps -a --filter "label=devcontainer.local_folder=$WORKSPACE_ROOT" -q)

if [ -n "$CONTAINER_ID" ]; then
  docker stop "$CONTAINER_ID"
  docker rm "$CONTAINER_ID"
fi
