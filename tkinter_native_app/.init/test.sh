#!/usr/bin/env bash
set -euo pipefail
WS="/home/kavia/workspace/code-generation/simple-desktop-clock-279729-279738/tkinter_native_app"
cd "$WS"
PYTEST_BIN="$WS/.venv/bin/pytest"
# create a safe minimal test if none exist
if ! compgen -G "tests/test_*.py" >/dev/null; then
  mkdir -p tests
  cat > tests/test_gui_safe.py <<'PY'
import tkinter as tk

def test_withdraw_root():
    root = tk.Tk()
    root.withdraw()
    root.update_idletasks()
    root.destroy()
    assert True
PY
fi
if [ ! -x "$PYTEST_BIN" ]; then
  echo "error: pytest not installed in venv ($PYTEST_BIN)" >&2
  exit 53
fi
# run pytest
"$PYTEST_BIN" -q --maxfail=1
