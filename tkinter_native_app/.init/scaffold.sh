#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/simple-desktop-clock-279729-279738/tkinter_native_app"
cd "$WS"
# create venv if missing
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
# ensure pip present in venv
. .venv/bin/activate
python -m pip install --upgrade pip >/dev/null 2>&1 || true
deactivate
# ensure requirements.txt exists (can be empty)
: > requirements.txt
# create start wrapper (kept minimal) - already provided separately
