#!/usr/bin/env bash
# Fetches the exact GCam prebuilt required by this device repository.
# Run this before invoking any PixelOS/Soong build that includes GCam_sweet2.
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly APK_NAME="MGC_9.6.080_V52_ENG.apk"
readonly APK_DEST="${REPO_DIR}/system/product/app/GoogleCameraEng/GoogleCameraEng.apk"
readonly LIB_DEST="${REPO_DIR}/system/product/app/GoogleCameraEng/lib/arm64"

# Override GCAM_APK_URL only to use a trusted mirror or your own release asset.
readonly GCAM_APK_URL="${GCAM_APK_URL:-https://1-dontsharethislink.celsoazevedo.com/file/filesc/MGC_9.6.080_V52_ENG.apk}"
readonly GCAM_APK_SHA256="${GCAM_APK_SHA256:-e13b884963a0f5a904f99358d120e3b96774f560c2403a7114812af3f7dd371c}"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command not found: $1" >&2
    exit 1
  }
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

download() {
  local destination="$1"
  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --retry 3 --output "$destination" "$GCAM_APK_URL"
  elif command -v wget >/dev/null 2>&1; then
    wget --https-only --tries=3 --output-document="$destination" "$GCAM_APK_URL"
  else
    echo "error: install curl or wget to download the GCam prebuilt" >&2
    exit 1
  fi
}

require_command unzip
mkdir -p "$(dirname "$APK_DEST")" "$LIB_DEST"

if [[ -f "$APK_DEST" ]] && [[ "$(sha256_of "$APK_DEST")" == "$GCAM_APK_SHA256" ]]; then
  echo "Using verified existing APK: $APK_DEST"
else
  tmp_apk="$(mktemp "${TMPDIR:-/tmp}/${APK_NAME}.XXXXXX")"
  trap 'rm -f "$tmp_apk"' EXIT
  echo "Downloading ${APK_NAME}..."
  download "$tmp_apk"

  actual_sha256="$(sha256_of "$tmp_apk")"
  if [[ "$actual_sha256" != "$GCAM_APK_SHA256" ]]; then
    echo "error: APK SHA-256 mismatch" >&2
    echo "expected: $GCAM_APK_SHA256" >&2
    echo "actual:   $actual_sha256" >&2
    exit 1
  fi
  mv "$tmp_apk" "$APK_DEST"
  trap - EXIT
fi

unzip -tq "$APK_DEST" >/dev/null
rm -f "$LIB_DEST"/*.so
unzip -j -o "$APK_DEST" 'lib/arm64-v8a/*.so' -d "$LIB_DEST" >/dev/null

lib_count="$(find "$LIB_DEST" -maxdepth 1 -type f -name '*.so' | wc -l | tr -d ' ')"
if [[ "$lib_count" -eq 0 ]]; then
  echo "error: no arm64 native libraries were found in the APK" >&2
  exit 1
fi

echo "GCam prebuilt is ready."
echo "APK SHA-256: $(sha256_of "$APK_DEST")"
echo "Extracted arm64 libraries: $lib_count"
