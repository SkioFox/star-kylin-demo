#!/usr/bin/env bash

set -euo pipefail

bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app_deb="$bundle_dir/star-kylin-demo_0.1.0-20260726.3_amd64.deb"
webengine_deb="$bundle_dir/repo/libqt5webengine5_5.12.12-0kylin1k0.9_amd64.deb"
qml_deb="$bundle_dir/repo/qml-module-qtwebengine_5.12.12-0kylin1k0.9_amd64.deb"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this installer with sudo: sudo ./install.sh" >&2
  exit 1
fi

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
  echo "This bundle supports amd64 only." >&2
  exit 1
fi

for package in "$app_deb" "$webengine_deb" "$qml_deb"; do
  if [[ ! -f "$package" ]]; then
    echo "Missing bundle file: $package" >&2
    exit 1
  fi
done

cd "$bundle_dir"
sha256sum -c SHA256SUMS

# All package paths are local and --no-download prevents any network access.
apt-get --no-download install "$webengine_deb" "$qml_deb" "$app_deb"
