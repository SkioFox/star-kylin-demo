#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app_dir="$(cd "$script_dir/.." && pwd)"
host_os="$(uname -s)"
host_arch="$(uname -m)"

case "$host_os" in
  Darwin)
    default_build_dir="$app_dir/build-local-macos"
    default_qt_prefix="$HOME/Qt/5.15.2/clang_64"
    ;;
  Linux)
    default_build_dir="$app_dir/build-local-linux-$host_arch"
    default_qt_prefix=""
    ;;
  *)
    printf 'Unsupported host OS: %s\n' "$host_os" >&2
    exit 1
    ;;
esac

build_dir="${KYLIN_SKY_BUILD_DIR:-$default_build_dir}"
qt_prefix="${QT_PREFIX:-$default_qt_prefix}"
pid_file="$build_dir/kylin-sky-demo.pid"
log_file="$build_dir/kylin-sky-demo.log"

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

find_cmake() {
  if [[ -n "${CMAKE_COMMAND:-}" ]]; then
    printf '%s\n' "$CMAKE_COMMAND"
    return
  fi
  if command -v cmake >/dev/null 2>&1; then
    command -v cmake
    return
  fi
  local candidate
  for candidate in "$HOME"/.local/opt/cmake-*/CMake.app/Contents/bin/cmake; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  die "Missing CMake 3.16+. Set CMAKE_COMMAND or install CMake."
}

find_ctest() {
  local alongside="$(dirname "$cmake_bin")/ctest"
  if [[ -x "$alongside" ]]; then
    printf '%s\n' "$alongside"
  elif command -v ctest >/dev/null 2>&1; then
    command -v ctest
  else
    die "Missing ctest next to CMake or in PATH."
  fi
}

find_qmake() {
  if [[ -n "$qt_prefix" && -x "$qt_prefix/bin/qmake" ]]; then
    printf '%s\n' "$qt_prefix/bin/qmake"
  elif command -v qmake >/dev/null 2>&1; then
    command -v qmake
  elif command -v qmake-qt5 >/dev/null 2>&1; then
    command -v qmake-qt5
  else
    die "Missing Qt 5 qmake. Install Qt 5 with Qt WebEngine or set QT_PREFIX."
  fi
}

cmake_bin="$(find_cmake)"
ctest_bin="$(find_ctest)"

doctor() {
  [[ -x "$cmake_bin" ]] || die "CMake is not executable: $cmake_bin"
  if [[ -n "$qt_prefix" ]]; then
    [[ -f "$qt_prefix/lib/cmake/Qt5/Qt5Config.cmake" ]] \
      || die "Missing Qt 5 at $qt_prefix. Set QT_PREFIX to a Qt 5 install."
    [[ -f "$qt_prefix/lib/cmake/Qt5WebEngine/Qt5WebEngineConfig.cmake" ]] \
      || die "Qt WebEngine is missing at $qt_prefix. Install the qtwebengine module."
  fi
  local qmake_bin
  qmake_bin="$(find_qmake)"
  printf 'Host: %s %s\n' "$host_os" "$host_arch"
  printf 'CMake: %s\n' "$("$cmake_bin" --version | sed -n '1p')"
  printf 'Qt: %s (%s)\n' "$("$qmake_bin" -query QT_VERSION)" "$("$qmake_bin" -query QT_INSTALL_PREFIX)"
  printf 'Build: %s\n' "$build_dir"
  if [[ "$host_os" == "Darwin" && "$host_arch" == "arm64" ]]; then
    printf '%s\n' "Apple Silicon uses the project's Qt 5 x86_64/Rosetta route; see the team guide."
  fi
}

configure() {
  doctor
  local args=(
    -S "$app_dir"
    -B "$build_dir"
    -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Debug}"
    -DBUILD_TESTING=ON
  )
  if [[ -n "$qt_prefix" ]]; then
    args+=("-DCMAKE_PREFIX_PATH=$qt_prefix")
  fi
  if [[ "$host_os" == "Darwin" ]]; then
    args+=("-DCMAKE_OSX_ARCHITECTURES=${KYLIN_SKY_MACOS_ARCH:-x86_64}")
  fi
  "$cmake_bin" "${args[@]}"
}

build() {
  configure
  "$cmake_bin" --build "$build_dir" --parallel "${KYLIN_SKY_BUILD_JOBS:-2}"
}

test_app() {
  build
  "$ctest_bin" --test-dir "$build_dir" --output-on-failure
}

app_binary() {
  local bundled="$build_dir/kylin-sky-demo.app/Contents/MacOS/kylin-sky-demo"
  local plain="$build_dir/kylin-sky-demo"
  if [[ -x "$bundled" ]]; then
    printf '%s\n' "$bundled"
  elif [[ -x "$plain" ]]; then
    printf '%s\n' "$plain"
  else
    die "Application binary is missing. Run: $0 build"
  fi
}

run() {
  build
  exec "$(app_binary)"
}

start() {
  build
  if [[ -f "$pid_file" ]] && kill -0 "$(<"$pid_file")" 2>/dev/null; then
    die "kylin-sky-demo is already running (PID $(<"$pid_file"))."
  fi
  "$(app_binary)" >"$log_file" 2>&1 &
  printf '%s\n' "$!" >"$pid_file"
  printf 'Started kylin-sky-demo (PID %s). Log: %s\n' "$(<"$pid_file")" "$log_file"
}

stop() {
  [[ -f "$pid_file" ]] || die "No local PID file found. Close the application window if it was started with run."
  local pid
  pid="$(<"$pid_file")"
  [[ "$pid" =~ ^[0-9]+$ ]] || die "Invalid PID file: $pid_file"
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    printf 'Stopped kylin-sky-demo (PID %s).\n' "$pid"
  fi
  rm -f "$pid_file"
}

clean() {
  [[ -f "$build_dir/CMakeCache.txt" ]] || die "No configured local build at $build_dir"
  "$cmake_bin" --build "$build_dir" --target clean
}

docker_platform() {
  case "$host_arch" in
    x86_64|amd64) printf '%s\n' amd64 ;;
    arm64|aarch64) printf '%s\n' arm64 ;;
    *) die "Unsupported Docker architecture: $host_arch" ;;
  esac
}

docker_test() {
  command -v docker >/dev/null 2>&1 || die "Docker is required for docker-test."
  docker info >/dev/null 2>&1 || die "Docker daemon is not running."
  local platform image container_build_dir
  platform="$(docker_platform)"
  image="kylin-sky-dev:$platform"
  container_build_dir="build-local-container-$platform"
  docker build --platform "linux/$platform" -t "$image" "$app_dir/packaging/docker"
  docker run --rm --platform "linux/$platform" -v "$app_dir:/workspace" -w /workspace "$image" \
    bash -lc "cmake -S . -B $container_build_dir -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Debug && cmake --build $container_build_dir --parallel 2 && ctest --test-dir $container_build_dir --output-on-failure"
}

usage() {
  printf '%s\n' "Usage: $0 {doctor|configure|build|test|run|start|stop|clean|docker-test}"
}

case "${1:-}" in
  doctor) doctor ;;
  configure) configure ;;
  build) build ;;
  test) test_app ;;
  run) run ;;
  start) start ;;
  stop) stop ;;
  clean) clean ;;
  docker-test) docker_test ;;
  *) usage; exit 2 ;;
esac
