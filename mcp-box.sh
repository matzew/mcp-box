#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"${SCRIPT_DIR}/scripts/00-installer-kind.sh"
"${SCRIPT_DIR}/scripts/01-mcp-lifecycle-operator.sh"
"${SCRIPT_DIR}/scripts/02-gateway-api-istio.sh"
"${SCRIPT_DIR}/scripts/03-mcp-gateway.sh"
"${SCRIPT_DIR}/scripts/04-mcp-launcher.sh"
