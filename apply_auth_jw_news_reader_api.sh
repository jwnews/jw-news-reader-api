#!/usr/bin/env bash
set -euo pipefail

# Configuration (override via environment variables)
: "${KUBECTL_BIN:=kubectl}"
: "${KUBECONFIG:=}"
: "${KUBE_CONTEXT:=}"
: "${NAMESPACE:=default}"
: "${MANIFEST:=/Users/brunomassaini/Git/JWNews/jw-news-reader/k8s/jw-news-reader-api-auth.yaml}"
: "${API_KEY:=}"

if [[ -n "${KUBECONFIG}" ]]; then
  export KUBECONFIG
fi

kubectl_base=("${KUBECTL_BIN}")
if [[ -n "${KUBE_CONTEXT}" ]]; then
  kubectl_base+=("--context" "${KUBE_CONTEXT}")
fi

if ! command -v "${KUBECTL_BIN}" >/dev/null 2>&1; then
  echo "kubectl not found: ${KUBECTL_BIN}" >&2
  exit 1
fi

if [[ ! -f "${MANIFEST}" ]]; then
  echo "Manifest not found: ${MANIFEST}" >&2
  exit 1
fi

# Apply KongPlugin/KongConsumer manifests
"${kubectl_base[@]}" apply -f "${MANIFEST}"

# Create key-auth credential Secret if missing
if ! "${kubectl_base[@]}" -n "${NAMESPACE}" get secret jw-news-reader-api-key-auth-cred >/dev/null 2>&1; then
  if [[ -z "${API_KEY}" ]]; then
    API_KEY="$(openssl rand -hex 32)"
  fi

  "${kubectl_base[@]}" -n "${NAMESPACE}" create secret generic jw-news-reader-api-key-auth-cred \
    --from-literal=key="${API_KEY}" \
    --dry-run=client -o yaml | \
    "${kubectl_base[@]}" label --local -f - konghq.com/credential=key-auth -o yaml | \
    "${kubectl_base[@]}" apply -f -

  echo "API key generated (store this safely): ${API_KEY}"
else
  echo "Secret jw-news-reader-api-key-auth-cred already exists; not regenerating."
fi

# Attach plugin to the Service (no Ingress changes)
"${kubectl_base[@]}" -n "${NAMESPACE}" annotate service jw-news-reader-api \
  konghq.com/plugins=jw-news-reader-api-key-auth --overwrite
