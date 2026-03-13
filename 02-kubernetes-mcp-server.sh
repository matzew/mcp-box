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

function header_text {
  echo "$header$*$reset"
}

header_text "Installing Kubernetes MCP Server"

kubectl apply -n kubernetes-mcp-server -f - << EOF
---
# Namespace for the kubernetes-mcp-server
apiVersion: v1
kind: Namespace
metadata:
  name: kubernetes-mcp-server
---
# ServiceAccount for the kubernetes-mcp-server with write access
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mcp-editor
  namespace: kubernetes-mcp-server
---
# ClusterRoleBinding to grant read/write access across the cluster
# Uses the built-in 'edit' ClusterRole which provides read/write access
# to most namespaced resources but excludes RBAC and cluster-level resources
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mcp-editor-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit  # Built-in ClusterRole with read/write permissions
subjects:
  - kind: ServiceAccount
    name: mcp-editor
    namespace: kubernetes-mcp-server
---
# ClusterRole to manage MCPServer custom resources
# The built-in 'edit' ClusterRole does not cover CRDs
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: mcp-editor-mcpservers
rules:
  - apiGroups: ["mcp.x-k8s.io"]
    resources: ["mcpservers"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mcp-editor-mcpservers-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: mcp-editor-mcpservers
subjects:
  - kind: ServiceAccount
    name: mcp-editor
    namespace: kubernetes-mcp-server
---
# ConfigMap containing the kubernetes-mcp-server configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: kubernetes-mcp-server-config
  namespace: kubernetes-mcp-server
data:
  config.toml: |
    # Kubernetes MCP Server Configuration
    log_level = 5
    port = "8080"
    read_only = false
    toolsets = ["core", "config"]

    # Deny access to sensitive resources
    denied_resources = [
      { group = "", version = "v1", kind = "Secret" },
      { group = "rbac.authorization.k8s.io", version = "v1", kind = "Role" },
      { group = "rbac.authorization.k8s.io", version = "v1", kind = "RoleBinding" },
      { group = "rbac.authorization.k8s.io", version = "v1", kind = "ClusterRole" },
      { group = "rbac.authorization.k8s.io", version = "v1", kind = "ClusterRoleBinding" },
    ]
---
# MCPServer resource with ServiceAccount for RBAC and write access
apiVersion: mcp.x-k8s.io/v1alpha1
kind: MCPServer
metadata:
  name: kubernetes-mcp-server
  namespace: kubernetes-mcp-server
spec:
  image: quay.io/containers/kubernetes_mcp_server:latest
  port: 8080
  serviceAccountName: mcp-editor  # Use the ServiceAccount with read/write RBAC permissions
  configMapRef:
    name: kubernetes-mcp-server-config
  args:
    - --config
    - /etc/mcp-config/config.toml
---
EOF
