#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/simple-desktop-clock-279729-279738/tkinter_native_app"
cd "$WS"
PIDFILE="$WS/app.pid"
# invoke canonical start
if [ ! -f "$PIDFILE" ]; then
  "$WS"/start >/dev/null 2>&1 || true
  TRIES=0
  while [ $TRIES -lt 10 ] && [ ! -f "$PIDFILE" ]; do
    sleep 1
    TRIES=$((TRIES+1))
  done
fi
if [ ! -f "$PIDFILE" ]; then
  echo "error: pidfile missing after start" >&2
  exit 60
fi
APP_PID=$(cat "$PIDFILE")
if ! ps -p "$APP_PID" >/dev/null 2>&1; then
  echo "error: app process $APP_PID not running" >&2
  exit 61
fi
START_OK=0
if [ -r "/proc/$APP_PID/cmdline" ]; then
  CMDLINE=$(tr '\0' ' ' < "/proc/$APP_PID/cmdline" || true)
  if echo "$CMDLINE" | grep -q ".venv/bin/python"; then
    START_OK=1
  else
    echo "error: running process does not appear to be venv python: $CMDLINE" >&2
    START_OK=0
  fi
else
  START_OK=0
fi
# Run tests if pytest present
PYTEST_BIN="$WS/.venv/bin/pytest"
if [ -x "$PYTEST_BIN" ]; then
  "$PYTEST_BIN" -q --maxfail=1 || { TEST_RC=$?; echo "error: tests failed (rc=$TEST_RC)" >&2; 
    kill "$APP_PID" >/dev/null 2>&1 || true; sleep 1; kill -9 "$APP_PID" >/dev/null 2>&1 || true; rm -f "$PIDFILE" || true; exit $TEST_RC; }
fi
# Stop the app gracefully
kill "$APP_PID" >/dev/null 2>&1 || true
sleep 1
if ps -p "$APP_PID" >/dev/null 2>&1; then
  kill -9 "$APP_PID" >/dev/null 2>&1 || true
fi
rm -f "$PIDFILE" || true
if [ "$START_OK" -ne 1 ]; then
  echo "warning: start verification incomplete; see earlier messages" >&2
fi
echo "validation_complete"
