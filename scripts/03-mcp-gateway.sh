#!/usr/bin/env bash

set -e

NO_COLOR=${NO_COLOR:-""}
if [ -z "$NO_COLOR" ]; then
  header=$'\e[1;33m'
  reset=$'\e[0m'
else
  header=''
  reset=''
fi

MCP_GATEWAY_VERSION=${MCP_GATEWAY_VERSION:-0.5.1}
MCP_GATEWAY_HOST=${MCP_GATEWAY_HOST:-mcp.127-0-0-1.sslip.io}

function header_text {
  echo "$header$*$reset"
}

header_text "Installing MCP Gateway v${MCP_GATEWAY_VERSION}"

kubectl create namespace gateway-system --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install mcp-gateway oci://ghcr.io/kuadrant/charts/mcp-gateway \
    --create-namespace \
    --namespace mcp-system \
    --version $MCP_GATEWAY_VERSION \
    --set broker.create=true \
    --set gateway.create=true \
    --set gateway.name=mcp-gateway \
    --set gateway.namespace=gateway-system \
    --set gateway.publicHost=$MCP_GATEWAY_HOST \
    --set gateway.nodePort.create=true \
    --set gateway.nodePort.mcpPort=30080 \
    --set envoyFilter.name=mcp-gateway \
    --set mcpGatewayExtension.gatewayRef.name=mcp-gateway \
    --set mcpGatewayExtension.gatewayRef.namespace=gateway-system \
    --set broker.pollInterval=10

header_text "Waiting for MCP Gateway to become ready"
for deploy in mcp-gateway mcp-gateway-controller; do
    until kubectl get deployment "$deploy" -n mcp-system &>/dev/null; do
        echo "  Waiting for deployment/$deploy to exist..."
        sleep 5
    done
done
kubectl wait deployment --all --timeout=300s --for=condition=Available -n mcp-system

header_text "Waiting for Istio gateway pod"
kubectl wait --for=condition=ready --timeout=300s pod -l gateway.networking.k8s.io/gateway-name=mcp-gateway -n gateway-system

header_text "MCP Gateway is ready!"
echo ""
echo "  To access the MCP Gateway, run:"
echo "    kubectl port-forward -n mcp-system svc/mcp-gateway 8080:8080"
echo ""
echo "  Then use: http://localhost:8080/mcp"
