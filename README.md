# 📦 MCP Box

A local Kubernetes playground for [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers, powered by [Kind](https://kind.sigs.k8s.io/), the [MCP Lifecycle Operator](https://github.com/kubernetes-sigs/mcp-lifecycle-operator), and [MCP Gateway](https://github.com/Kuadrant/mcp-gateway).

Spin up a fully working MCP environment on your machine — a Kind cluster, Gateway API with Istio, the MCP Gateway for federated tool access, and the [MCP Launcher](https://github.com/matzew/mcp-launcher) web UI for browsing and deploying MCP servers from a catalog.

## ✨ Features

- 🌐 **MCP Gateway** — Federated access to all MCP servers through a single endpoint
- 🚪 **Gateway API + Istio** — Envoy-based gateway with ext_proc routing, no service mesh required
- 🚀 **MCP Launcher** — Web UI to browse, configure, and deploy MCP servers from a catalog
- 🔌 **Auto-registration** — Launcher automatically creates `HTTPRoute` and `MCPServerRegistration` for each deployed server
- 🧩 **MCP Lifecycle Operator** — Manages MCP server pods via `MCPServer` custom resources
- 📦 **Single command setup** — `./mcp-box.sh` gets you from zero to a working MCP gateway

## 🏗️ Architecture

```
                        localhost:7001 (NodePort)
                              │
┌─────────────────────────────┼───────────────────────────────┐
│                   Kind Cluster                              │
│                             │                               │
│  ┌──────────────────────────┼────────────────────────────┐  │
│  │  gateway-system          │                            │  │
│  │  ├─ Istio (Gateway API provider)                      │  │
│  │  └─ mcp-gateway (Envoy + ext_proc)                    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  mcp-system                                           │  │
│  │  ├─ MCP Gateway broker + router                       │  │
│  │  ├─ MCP Gateway controller                            │  │
│  │  └─ MCP Launcher (web UI)                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  mcp-catalog                                          │  │
│  │  └─ Catalog ConfigMaps (server entries)               │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  kubernetes-mcp-server (optional, script 05)          │  │
│  │  ├─ MCPServer CR                                      │  │
│  │  ├─ HTTPRoute + MCPServerRegistration (kube_ prefix)  │  │
│  │  └─ ServiceAccount (mcp-editor)                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

- [Kind](https://kind.sigs.k8s.io/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- A container runtime — [Podman](https://podman.io/) (Linux) or Docker (macOS)

## 🚀 Getting Started

Run everything with a single command:

```bash
./mcp-box.sh
```

This installs the full platform: Kind cluster, MCP Lifecycle Operator, Istio, MCP Gateway, and the Launcher UI.

### ➕ Optional: Kubernetes MCP Server

Deploy the [Kubernetes MCP Server](https://github.com/containers/kubernetes-mcp-server) with gateway integration (`kube_` tool prefix):

```bash
./scripts/05-kubernetes-mcp-server.sh
```

### 🔧 Gateway infrastructure only

Use `install-base.sh` to set up the gateway stack without the Launcher:

```bash
./install-base.sh
```

## 📁 Individual Scripts

```bash
./scripts/00-installer-kind.sh          # 1️⃣  Create Kind cluster (NodePort on 7001)
./scripts/01-mcp-lifecycle-operator.sh  # 2️⃣  Install MCP Lifecycle Operator
./scripts/02-gateway-api-istio.sh       # 3️⃣  Install Istio as Gateway API provider
./scripts/03-mcp-gateway.sh            # 4️⃣  Install MCP Gateway
./scripts/04-mcp-launcher.sh           # 5️⃣  Deploy MCP Launcher (web UI + catalog)
./scripts/05-kubernetes-mcp-server.sh  # 6️⃣  Deploy Kubernetes MCP Server (optional)
```

## 🔍 What Each Script Does

| Script | Description |
|--------|-------------|
| `mcp-box.sh` | 🎁 Wrapper that runs scripts 00–04 in order |
| `install-base.sh` | 🔧 Runs scripts 00–03 (gateway infrastructure only) |
| `00-installer-kind.sh` | 🏗️ Creates a Kind cluster with NodePort mapping (host 7001 → container 30080), patches CoreDNS for external resolution |
| `01-mcp-lifecycle-operator.sh` | ⚙️ Installs the MCP Lifecycle Operator and waits for readiness |
| `02-gateway-api-istio.sh` | 🚪 Installs Istio as a Gateway API provider (no service mesh, just the gateway) |
| `03-mcp-gateway.sh` | 🌐 Installs MCP Gateway (broker, router, controller) with NodePort service |
| `04-mcp-launcher.sh` | 🚀 Installs the [MCP Launcher](https://github.com/matzew/mcp-launcher) web UI with sample catalog entries |
| `05-kubernetes-mcp-server.sh` | 🧩 Deploys the [Kubernetes MCP Server](https://github.com/containers/kubernetes-mcp-server) with `HTTPRoute` + `MCPServerRegistration` (`kube_` prefix). Not run by `mcp-box.sh` |

## ✅ Verifying the Setup

Check that all pods are running:

```bash
kubectl get pods -A
```

Check registered MCP servers on the gateway:

```bash
kubectl get mcpserverregistrations.mcp.kuadrant.io -A
```

## 🌐 Accessing the Gateway

The gateway is exposed via NodePort on `localhost:7001`:

```
http://localhost:7001/mcp
```

Or via port-forward:

```bash
kubectl port-forward -n gateway-system svc/mcp-gateway-istio 8001:8080
# → http://localhost:8001/mcp
```

## 🚀 Accessing the MCP Launcher

```bash
kubectl port-forward -n mcp-system svc/mcp-launcher 9090:8080
```

Then open [http://localhost:9090](http://localhost:9090) in your browser.

## 🔎 MCP Inspector

Test the gateway with the [MCP Inspector](https://github.com/modelcontextprotocol/inspector):

```bash
podman run --rm --network host ghcr.io/modelcontextprotocol/inspector:latest
```

Open [http://localhost:6274](http://localhost:6274) and connect to `http://localhost:7001/mcp`.

## 🧹 Cleanup

Delete the entire Kind cluster:

```bash
kind delete cluster
```

## 📄 License

Apache License 2.0 — see [LICENSE](LICENSE).
