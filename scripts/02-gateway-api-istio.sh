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

function header_text {
  echo "$header$*$reset"
}

header_text "Installing Gateway API CRDs"
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

header_text "Installing Istio via Helm"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm upgrade --install istio-base istio/base -n istio-system --create-namespace --wait
helm upgrade --install istiod istio/istiod -n istio-system --wait

header_text "Waiting for Istio to become ready"
kubectl wait deployment --all --timeout=300s --for=condition=Available -n istio-system
