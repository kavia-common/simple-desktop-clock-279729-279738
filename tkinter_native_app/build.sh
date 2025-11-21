#!/usr/bin/env bash
# A simple build helper for the tkinter_native_app container.
# Uses strict mode to avoid common bash pitfalls and syntax errors.
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-tkinter_native_app:latest}"
CONTEXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[INFO] Building image: ${IMAGE_NAME}"
docker build --pull --no-cache -t "${IMAGE_NAME}" "${CONTEXT_DIR}"

echo "[INFO] Build completed for ${IMAGE_NAME}"

# Optional run helper with X11 forwarding (Linux host):
# To run a Tkinter GUI app from inside Docker on a Linux host with X11:
#   xhost +local:root
#   docker run --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw ${IMAGE_NAME}
#   xhost -local:root
#
# On systems without a real display (CI), consider xvfb:
#   docker run --rm ${IMAGE_NAME} bash -lc "xvfb-run -a python app.py"
