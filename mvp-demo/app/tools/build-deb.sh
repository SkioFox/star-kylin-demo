#!/usr/bin/env bash

set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$(uname -m)" in
  aarch64|arm64)
    deb_arch="arm64"
    ;;
  x86_64|amd64)
    deb_arch="amd64"
    ;;
  *)
    echo "Unsupported build architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

expected_arch="${STAR_KYLIN_EXPECTED_DEB_ARCH:-$deb_arch}"
if [[ "$expected_arch" != "$deb_arch" ]]; then
  echo "Build host is $deb_arch, expected $expected_arch. Refusing to relabel the package." >&2
  exit 1
fi

build_dir="${STAR_KYLIN_BUILD_DIR:-$root_dir/build-release-$deb_arch}"
staging_dir="${STAR_KYLIN_STAGING_DIR:-$root_dir/staging-$deb_arch}"
output_dir="${STAR_KYLIN_OUTPUT_DIR:-$root_dir/dist/$deb_arch}"

cmake_args=(
  -S "$root_dir"
  -B "$build_dir"
  -DBUILD_TESTING=ON
  -DCMAKE_BUILD_TYPE=Release
)

if [[ -n "${STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS:-}" ]]; then
  cmake_args+=(
    "-DSTAR_KYLIN_DEBIAN_RUNTIME_DEPENDS=${STAR_KYLIN_DEBIAN_RUNTIME_DEPENDS}"
  )
fi

cmake "${cmake_args[@]}"
cmake --build "$build_dir" --parallel "${STAR_KYLIN_BUILD_JOBS:-2}"
ctest --test-dir "$build_dir" --output-on-failure

cmake -E remove_directory "$staging_dir"
cmake -E remove_directory "$output_dir"
cmake -E make_directory "$staging_dir" "$output_dir"
cmake --install "$build_dir" --prefix "$staging_dir"
cpack --config "$build_dir/CPackConfig.cmake" -B "$output_dir"

packages=("$output_dir"/star-kylin-demo_*_"$deb_arch".deb)
if [[ "${#packages[@]}" -ne 1 || ! -f "${packages[0]}" ]]; then
  echo "Expected exactly one $deb_arch package in $output_dir." >&2
  exit 1
fi
package_path="${packages[0]}"

actual_arch="$(dpkg-deb --field "$package_path" Architecture)"
if [[ "$actual_arch" != "$deb_arch" ]]; then
  echo "Package architecture is $actual_arch, expected $deb_arch." >&2
  exit 1
fi

(cd "$output_dir" && sha256sum "$(basename "$package_path")" >"$(basename "$package_path").sha256")
dpkg-deb --info "$package_path"
printf 'Package: %s\nChecksum: %s.sha256\n' "$package_path" "$package_path"
