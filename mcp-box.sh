#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"${SCRIPT_DIR}/scripts/00-installer-kind.sh"
"${SCRIPT_DIR}/scripts/01-mcp-lifecycle-operator.sh"
"${SCRIPT_DIR}/scripts/02-kubernetes-mcp-server.sh"
"${SCRIPT_DIR}/scripts/03-mcp-launcher.sh"
