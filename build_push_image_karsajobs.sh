#!/bin/bash


set -e

GITHUB_USERNAME="handikaawork-star"

REGISTRY="ghcr.io"

IMAGE_NAME="${REGISTRY}/${GITHUB_USERNAME}/karsajobs"

IMAGE_TAG="latest"


if [ -z "${CR_PAT}" ]; then
  echo "ERROR: environment variable CR_PAT belum diatur."
  echo "Jalankan terlebih dahulu: export CR_PAT=<personal_access_token>"
  exit 1
fi


echo ">> [1/3] Membangun image ${IMAGE_NAME}:${IMAGE_TAG}"


docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .



echo ">> [2/3] Login ke ${REGISTRY}"


echo "${CR_PAT}" | docker login "${REGISTRY}" -u "${GITHUB_USERNAME}" --password-stdin

echo ">> [3/3] Mengunggah image ke ${REGISTRY}"

docker push "${IMAGE_NAME}:${IMAGE_TAG}"

echo ">> Selesai. Image tersedia di: ${IMAGE_NAME}:${IMAGE_TAG}"