#!/usr/bin/env bash

set -euo pipefail

output_dir="${1:-output/qt5-smoke}"
display_number="${DISPLAY_NUMBER:-99}"
display=":${display_number}"
screen_width="${SCREEN_WIDTH:-1366}"
screen_height="${SCREEN_HEIGHT:-768}"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp/star-kylin-runtime}"
app_log="${APP_LOG:-/tmp/star-kylin-app.log}"
web_wait_seconds="${WEB_WAIT_SECONDS:-8}"
kline_wait_seconds="${KLINE_WAIT_SECONDS:-1}"
capture_kline_interactions="${CAPTURE_KLINE_INTERACTIONS:-0}"
capture_web_policy="${CAPTURE_WEB_POLICY:-0}"
capture_native_dialog="${CAPTURE_NATIVE_DIALOG:-0}"
login_username="${LOGIN_USERNAME:-}"

mkdir -p "$output_dir"
rm -rf "$runtime_dir"
mkdir -m 700 "$runtime_dir"
rm -f "/tmp/.X${display_number}-lock" "$app_log"

Xvfb "$display" -screen 0 "${screen_width}x${screen_height}x24" -nolisten tcp >/tmp/star-kylin-xvfb.log 2>&1 &
xvfb_pid=$!
app_pid=""

cleanup() {
  if [[ -n "$app_pid" ]]; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi
  kill "$xvfb_pid" 2>/dev/null || true
  wait "$xvfb_pid" 2>/dev/null || true
}
trap cleanup EXIT

export DISPLAY="$display"
export XDG_RUNTIME_DIR="$runtime_dir"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"
export QTWEBENGINE_DISABLE_SANDBOX="${QTWEBENGINE_DISABLE_SANDBOX:-1}"

display_ready=false
for _ in $(seq 1 30); do
  if ! kill -0 "$xvfb_pid" 2>/dev/null; then
    cat /tmp/star-kylin-xvfb.log
    echo "Xvfb exited before becoming ready." >&2
    exit 1
  fi
  if xdotool getmouselocation >/dev/null 2>&1; then
    display_ready=true
    break
  fi
  sleep 0.1
done
if [[ "$display_ready" != "true" ]]; then
  cat /tmp/star-kylin-xvfb.log
  echo "Xvfb did not become ready." >&2
  exit 1
fi
sleep 0.2

./build-docker/star-kylin-demo >"$app_log" 2>&1 &
app_pid=$!

window=""
for _ in $(seq 1 50); do
  window=$(xdotool search --onlyvisible --pid "$app_pid" 2>/dev/null | head -n 1 || true)
  [[ -n "$window" ]] && break
  sleep 0.1
done

if [[ -z "$window" ]]; then
  cat "$app_log"
  echo "Unable to locate the application window." >&2
  exit 1
fi

xdotool windowmove "$window" 0 0
xdotool windowsize "$window" "$screen_width" "$screen_height"
xdotool windowfocus --sync "$window"
sleep 0.5
import -display "$DISPLAY" -window root "$output_dir/login-${screen_width}x${screen_height}.png"

if [[ -n "$login_username" ]]; then
  xdotool key ctrl+a
  xdotool type --clearmodifiers "$login_username"
fi
xdotool key Return
sleep 1
import -display "$DISPLAY" -window root "$output_dir/workbench-${screen_width}x${screen_height}.png"

if [[ "$capture_native_dialog" == "1" ]]; then
  xdotool mousemove --window "$window" 80 316 click 1
  sleep 1
  import -display "$DISPLAY" -window root "$output_dir/native-${screen_width}x${screen_height}.png"
fi

xdotool mousemove --window "$window" 80 232 click 1
sleep "$web_wait_seconds"
import -display "$DISPLAY" -window root "$output_dir/web-${screen_width}x${screen_height}.png"

if [[ "$capture_web_policy" == "1" ]]; then
  xdotool mousemove --window "$window" 600 405 click 1
  xdotool key Tab Tab Return
  sleep 1
  import -display "$DISPLAY" -window root "$output_dir/web-blocked-${screen_width}x${screen_height}.png"
fi

if [[ "$capture_native_dialog" != "1" ]]; then
  xdotool mousemove --window "$window" 80 316 click 1
  sleep "$kline_wait_seconds"
  import -display "$DISPLAY" -window root "$output_dir/kline-${screen_width}x${screen_height}.png"
fi

if [[ "$capture_kline_interactions" == "1" && "$capture_native_dialog" != "1" ]]; then
  xdotool mousemove --window "$window" 1142 159 click 1
  sleep "$kline_wait_seconds"
  import -display "$DISPLAY" -window root "$output_dir/kline-week-${screen_width}x${screen_height}.png"

  xdotool mousemove --window "$window" 1205 159 click 1
  sleep "$kline_wait_seconds"
  xdotool mousemove --window "$window" 700 350
  sleep 0.5
  import -display "$DISPLAY" -window root "$output_dir/kline-month-hover-${screen_width}x${screen_height}.png"

  xdotool mousemove --window "$window" 700 350 click 4
  sleep 0.5
  xdotool mousemove --window "$window" 1300 159 click 1
  sleep "$kline_wait_seconds"
fi

identify "$output_dir/login-${screen_width}x${screen_height}.png" \
  "$output_dir/workbench-${screen_width}x${screen_height}.png" \
  "$output_dir/web-${screen_width}x${screen_height}.png"
if [[ "$capture_native_dialog" != "1" ]]; then
  identify "$output_dir/kline-${screen_width}x${screen_height}.png"
fi
filtered_log="$(mktemp)"
grep -vFx "Sandboxing disabled by user." "$app_log" >"$filtered_log" || true
if [[ -s "$filtered_log" ]]; then
  cat "$filtered_log"
  exit 1
fi
