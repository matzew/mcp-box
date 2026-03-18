#!/usr/bin/env bash

set -e

# Turn colors in this script off by setting the NO_COLOR variable in your
# environment to any value:
#
# $ NO_COLOR=1 test.sh
NO_COLOR=${NO_COLOR:-""}
if [ -z "$NO_COLOR" ]; then
  header=$'\e[1;33m'
  reset=$'\e[0m'
else
  header=''
  reset=''
fi

mcp_launcher_url=https://raw.githubusercontent.com/matzew/mcp-launcher/refs/heads/main/dist/mcp-launcher.yaml

function header_text {
  echo "$header$*$reset"
}

header_text "Installing MCP Launcher"
kubectl apply --filename $mcp_launcher_url

header_text "Waiting for MCP Launcher to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n mcp-system
