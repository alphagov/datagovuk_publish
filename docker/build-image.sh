#!/bin/bash

set -eux

build () {
  if [ "${ARCH}" = "amd64" ]; then
    docker build . -t "ghcr.io/alphagov/${APP}:${2}${1}" -f "docker/${2}Dockerfile"
  else
    docker buildx build --platform "linux/${ARCH}" . -t "ghcr.io/alphagov/${APP}:${2}${1}" -f "docker/${2}Dockerfile"
  fi
}

DOCKER_TAG="${GITHUB_SHA}"

if [[ -n ${GH_REF:-} ]]; then
  DOCKER_TAG="${GH_REF}"
fi

if [[ -n ${DEV:-} ]]; then
  build "${DOCKER_TAG}" "dev."
else
  build "${DOCKER_TAG}" ""
fi

if [[ -n ${DRY_RUN:-} ]]; then
  echo "Dry run; not pushing to registry"
else
  if [[ -n ${DEV:-} ]]; then
    docker push "ghcr.io/alphagov/${APP}:dev.${DOCKER_TAG}"
  else
    docker push "ghcr.io/alphagov/${APP}:${DOCKER_TAG}"
  fi
fi
