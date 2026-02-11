#!/usr/bin/env bash
set -euo pipefail

APP_NAME="jw-news-reader-api"
DOCKER_REPOSITORY="brunomassaini"
IMAGE_NAME="${DOCKER_REPOSITORY}/${APP_NAME}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
FULL_IMAGE="$IMAGE_NAME:$IMAGE_TAG"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

docker build --platform "$DOCKER_PLATFORM" -t "$FULL_IMAGE" . # linux/arm64 for apple chips
docker push "$FULL_IMAGE"

kubectl apply -f k8s/
kubectl rollout status deployment/"$APP_NAME"

kubectl rollout restart deployment/"$APP_NAME"
