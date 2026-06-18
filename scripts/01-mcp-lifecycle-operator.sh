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

MLO_VERSION=${MLO_VERSION:-0.2.0}
mlo_url=https://github.com/kubernetes-sigs/mcp-lifecycle-operator/releases/download/v${MLO_VERSION}/install.yaml

function header_text {
  echo "$header$*$reset"
}

header_text "Setting up MCP Lifecycle Operator v${MLO_VERSION}"
kubectl apply --filename $mlo_url

header_text "Waiting for MCP Lifecycle Operator to become ready"
kubectl wait deployment --all --timeout=-1s --for=condition=Available -n mcp-lifecycle-operator-system
