#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/simple-desktop-clock-279729-279738/tkinter_native_app"
cd "$WS"
PIP="$WS/.venv/bin/pip"
PY="$WS/.venv/bin/python"
[ -x "$PIP" ] || { echo "error: pip not found in venv" >&2; exit 30; }
# Upgrade pip (show errors if any)
"$PIP" install --upgrade pip || { echo "error: pip upgrade failed" >&2; exit 31; }
# If requirements.txt has content, install it deterministically
if [ -s requirements.txt ]; then
  "$PIP" install --no-cache-dir -r requirements.txt || { echo "error: pip install requirements failed" >&2; exit 32; }
fi
# If tests exist, ensure pytest is installed into venv
if ls tests/*.py >/dev/null 2>&1 || [ -d tests ]; then
  if ! "$PIP" show pytest >/dev/null 2>&1; then
    "$PIP" install pytest || { echo "error: pytest install failed" >&2; exit 33; }
  fi
fi
# Validate tkinter import using venv python
if ! "$PY" - <<'PYCODE'
import sys
try:
    import tkinter
except Exception as e:
    print('error: venv tkinter import failed:', e, file=sys.stderr)
    sys.exit(34)
sys.exit(0)
PYCODE
then
  exit 34
fi
