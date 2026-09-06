#!/bin/bash

# Shebang di atas menandakan berkas ini dijalankan menggunakan interpreter bash.

# set -e membuat script BERHENTI seketika bila ada perintah yang gagal,
# sehingga kegagalan pada tahap build tidak diteruskan ke tahap push.
set -e

# ---------------------------------------------------------------------------
# Konfigurasi
# ---------------------------------------------------------------------------

# Username akun GitHub, dipakai untuk login sekaligus sebagai namespace image.
GITHUB_USERNAME="handikaawork-star"

# Alamat registry. ghcr.io adalah GitHub Container Registry.
REGISTRY="ghcr.io"

# Nama lengkap image mengikuti format: <registry>/<username>/<nama-image>
IMAGE_NAME="${REGISTRY}/${GITHUB_USERNAME}/karsajobs-ui"

# Tag menandai versi image. 'latest' sesuai ketentuan submission.
IMAGE_TAG="latest"

# ---------------------------------------------------------------------------
# Prasyarat
# ---------------------------------------------------------------------------

# Memastikan Personal Access Token sudah tersedia sebagai environment variable.
# Token sengaja TIDAK ditulis di dalam berkas ini agar tidak ikut ter-commit
# ke repository. Set terlebih dahulu dengan:  export CR_PAT=<token_anda>
if [ -z "${CR_PAT}" ]; then
  echo "ERROR: environment variable CR_PAT belum diatur."
  echo "Jalankan terlebih dahulu: export CR_PAT=<personal_access_token>"
  exit 1
fi

# Menampilkan isi .env sebagai pengingat sebelum build dimulai.
#
# PENTING: variabel berawalan VUE_APP_ dibaca oleh Vue CLI pada saat BUILD,
# lalu nilainya ditanam permanen ke dalam bundle JavaScript. Mengubah .env
# setelah image jadi TIDAK akan berpengaruh; image harus dibangun ulang.
echo ">> Isi berkas .env yang akan ikut ter-build:"
cat .env
echo ""

# ---------------------------------------------------------------------------
# Langkah 1: Build image dari Dockerfile
# ---------------------------------------------------------------------------

echo ">> [1/3] Membangun image ${IMAGE_NAME}:${IMAGE_TAG}"

# -t   memberi nama dan tag pada image hasil build.
# .    adalah build context, yaitu direktori tempat Dockerfile berada.
#      Script ini harus dijalankan dari dalam direktori karsajobs-ui.
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

# ---------------------------------------------------------------------------
# Langkah 2: Login ke GitHub Container Registry
# ---------------------------------------------------------------------------

echo ">> [2/3] Login ke ${REGISTRY}"

# --password-stdin membaca token dari standard input, bukan dari argumen,
# sehingga token tidak tersimpan di riwayat shell maupun terlihat pada
# daftar proses yang sedang berjalan.
echo "${CR_PAT}" | docker login "${REGISTRY}" -u "${GITHUB_USERNAME}" --password-stdin

# ---------------------------------------------------------------------------
# Langkah 3: Push image ke registry
# ---------------------------------------------------------------------------

echo ">> [3/3] Mengunggah image ke ${REGISTRY}"

docker push "${IMAGE_NAME}:${IMAGE_TAG}"

echo ">> Selesai. Image tersedia di: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ">> Jangan lupa ubah visibility package menjadi public di GitHub."