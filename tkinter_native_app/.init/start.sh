#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/simple-desktop-clock-279729-279738/tkinter_native_app"
cd "$WS"
PIDFILE="$WS/app.pid"
# start app using venv python via setsid, verify cmdline, then write pidfile
if [ -f "$PIDFILE" ]; then
  echo "start: pidfile exists"
  exit 0
fi
PY="$WS/.venv/bin/python"
if [ ! -x "$PY" ]; then
  echo "error: venv python not found at $PY" >&2
  exit 50
fi
# Ensure app entry exists (choose clock.py or main.py)
APPPY="$WS/clock.py"
if [ ! -f "$APPPY" ]; then
  APPPY="$WS/main.py"
fi
if [ ! -f "$APPPY" ]; then
  echo "error: no entrypoint (clock.py or main.py) found" >&2
  exit 51
fi
# Launch in new session to decouple and capture pid deterministically
setsid "$PY" "$APPPY" >/dev/null 2>&1 &
PID=$!
# wait for process to appear and verify it's the venv python
TRIES=0
while [ $TRIES -lt 10 ]; do
  if ps -p "$PID" >/dev/null 2>&1; then
    if [ -r "/proc/$PID/cmdline" ]; then
      CMD=$(tr '\0' ' ' < "/proc/$PID/cmdline" || true)
      if echo "$CMD" | grep -q ".venv/bin/python"; then
        echo "$PID" > "$PIDFILE"
        exit 0
      fi
    fi
  fi
  sleep 1
  TRIES=$((TRIES+1))
done
# fallback: kill and fail
kill "$PID" >/dev/null 2>&1 || true
sleep 1
kill -9 "$PID" >/dev/null 2>&1 || true
echo "error: failed to start verified venv python process" >&2
exit 52
