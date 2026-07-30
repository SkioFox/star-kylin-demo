#!/usr/bin/env bash

set -euo pipefail

bundle_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app_deb="$bundle_dir/kylin-sky-demo_0.2.1-4_amd64.deb"
webengine_deb="$bundle_dir/repo/libqt5webengine5_5.12.12-0kylin1k0.9_amd64.deb"
qml_deb="$bundle_dir/repo/qml-module-qtwebengine_5.12.12-0kylin1k0.9_amd64.deb"

require_installed_version() {
  local package="$1"
  local expected="$2"
  local actual

  if ! actual="$(dpkg-query -W -f='${Status} ${Version}' "$package" 2>/dev/null)" \
    || [[ "$actual" != "install ok installed $expected" ]]; then
    echo "Unsupported baseline: $package must be $expected (actual: ${actual:-not installed})." >&2
    exit 1
  fi
}

require_absent_or_version() {
  local package="$1"
  local expected="$2"
  local actual

  actual="$(dpkg-query -W -f='${Status} ${Version}' "$package" 2>/dev/null || true)"
  if [[ -n "$actual" && "$actual" != "install ok installed $expected" ]]; then
    echo "Unsupported baseline: $package is $actual; expected absent or $expected." >&2
    exit 1
  fi
}

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this installer with sudo: sudo ./install.sh" >&2
  exit 1
fi

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
  echo "This bundle supports amd64 only." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Unsupported system: /etc/os-release is missing." >&2
  exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "kylin" || "${PROJECT_CODENAME:-}" != "V10SP1" \
  || "${KYLIN_RELEASE_ID:-}" != "2503" ]]; then
  echo "This bundle requires Kylin V10 SP1 release 2503." >&2
  exit 1
fi

# Match the customer baseline instead of attempting a risky Qt runtime upgrade.
require_installed_version "libc6:amd64" "2.31-0kylin9.1k22.0"
require_installed_version "libqt5quickcontrols2-5:amd64" "5.12.12-0kylin1k0.3"
require_installed_version "libqt5svg5:amd64" "5.12.12-0kylin1k0.3"
require_installed_version "libqt5webengine-data" "5.12.12-0kylin1k0.9"
require_installed_version "libqt5webenginecore5:amd64" "5.12.12-0kylin1k0.9"
require_installed_version "qml-module-qtquick2:amd64" "5.12.12-0kylin1k0.3"
require_installed_version "qml-module-qtquick-controls2:amd64" "5.12.12-0kylin1k0.3"
require_installed_version "qml-module-qtquick-window2:amd64" "5.12.12-0kylin1k0.3"
require_absent_or_version "libqt5webengine5:amd64" "5.12.12-0kylin1k0.9"
require_absent_or_version "qml-module-qtwebengine:amd64" "5.12.12-0kylin1k0.9"

for package in "$app_deb" "$webengine_deb" "$qml_deb"; do
  if [[ ! -f "$package" ]]; then
    echo "Missing bundle file: $package" >&2
    exit 1
  fi
done

cd "$bundle_dir"
sha256sum -c SHA256SUMS

# All package paths are local and --no-download prevents any network access.
apt-get --no-download --yes install "$webengine_deb" "$qml_deb" "$app_deb"
