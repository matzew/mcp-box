# 📦 MCP Box

A local Kubernetes playground for [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers, powered by [Kind](https://kind.sigs.k8s.io/) and the [MCP Lifecycle Operator](https://github.com/kubernetes-sigs/mcp-lifecycle-operator).

Spin up a fully working MCP environment on your machine in minutes — a Kind cluster, the operator that manages MCP server lifecycles, and a ready-to-use [Kubernetes MCP Server](https://github.com/containers/kubernetes-mcp-server) instance.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Kind Cluster                      │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  mcp-lifecycle-operator-system                │  │
│  │  └─ MCP Lifecycle Operator (controller)       │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  kubernetes-mcp-server                        │  │
│  │  ├─ MCPServer CR (kubernetes-mcp-server)      │  │
│  │  ├─ ServiceAccount (mcp-editor)               │  │
│  │  └─ ConfigMap (server config)                 │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- [Kind](https://kind.sigs.k8s.io/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- A container runtime — [Podman](https://podman.io/) (Linux) or Docker (macOS)

## 🚀 Getting Started

Run the scripts in order:

```bash
# 1. Create a Kind cluster
./00-installer-kind.sh

# 2. Install the MCP Lifecycle Operator
./01-mcp-lifecycle-operator.sh

# 3. Deploy the Kubernetes MCP Server
./02-kubernetes-mcp-server.sh
```

Or run them all at once:

```bash
./00-installer-kind.sh && ./01-mcp-lifecycle-operator.sh && ./02-kubernetes-mcp-server.sh
```

## 🔍 What Each Script Does

| Script | Description |
|--------|-------------|
| `00-installer-kind.sh` | Creates a Kind cluster (uses Podman on Linux), waits for core services, and patches CoreDNS to use `8.8.8.8` for external resolution. |
| `01-mcp-lifecycle-operator.sh` | Installs the MCP Lifecycle Operator from the upstream distribution manifest and waits for the controller deployment to become ready. |
| `02-kubernetes-mcp-server.sh` | Creates the `kubernetes-mcp-server` namespace, a `ServiceAccount` with `edit` permissions, a server configuration `ConfigMap`, and an `MCPServer` custom resource that the operator reconciles into a running MCP server pod. |

## ✅ Verifying the Setup

After running all scripts, confirm everything is healthy:

```bash
kubectl get pods -A
```

You should see pods running in `kube-system`, `mcp-lifecycle-operator-system`, and `kubernetes-mcp-server`.

Check the MCP server resource:

```bash
kubectl get mcpservers -n kubernetes-mcp-server
```

## 🔌 Port Forwarding

To connect to the MCP server from your local machine (e.g. from a local MCP client or Claude Desktop):

```bash
kubectl port-forward -n kubernetes-mcp-server svc/kubernetes-mcp-server 8080:8080
```

The server will be available at `http://localhost:8080/mcp`.

## 🔎 MCP Inspector

You can use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector) to test and debug the MCP server. First, port-forward the MCP server as shown above, then run the inspector locally:

```bash
podman run --rm --network host ghcr.io/modelcontextprotocol/inspector:latest
```

Open http://localhost:6274 in your browser and connect to `http://localhost:8080/mcp`.

## 🧹 Cleanup

Delete the entire Kind cluster:

```bash
kind delete cluster
```

## 📄 License

[Apache License 2.0](LICENSE)
