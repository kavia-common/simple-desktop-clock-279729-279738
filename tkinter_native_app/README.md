# Tkinter Native App - Simple Desktop Clock

This container provides a simple Tkinter-based clock. The Dockerfile creates a dedicated Python virtual environment in /opt/venv, ensures pip is available, and installs dependencies from requirements.txt if present.

## Build

- Using the helper script:
  ./build.sh
  Optionally set IMAGE_NAME before building:
  IMAGE_NAME=myorg/tkinter_native_app:latest ./build.sh

- Using raw docker:
  docker build -t tkinter_native_app:latest .

Notes:
- The build installs system packages tk/tcl and python3-venv/python3-pip.
- A virtual environment is created at /opt/venv, pip is bootstrapped/updated, and any dependencies in requirements.txt are installed using /opt/venv/bin/pip.
- If requirements.txt is missing or empty, the build succeeds without installing extra packages.

## Run (Linux, X11 forwarding)

On a Linux host with X11:

1) Allow local docker to connect to X server
   xhost +local:root

2) Run the container with X11 mounts:
   docker run --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw tkinter_native_app:latest

3) Revoke permission after you are done:
   xhost -local:root

## Run (Headless with xvfb)

If no display is available (e.g., CI):

  docker run --rm tkinter_native_app:latest bash -lc "xvfb-run -a /opt/venv/bin/python app.py"

Note: xvfb is not installed in the image by default to keep the image slim. You can extend the Dockerfile or install at runtime if needed.

## Execution & Entrypoint

- The container CMD uses /opt/venv/bin/python app.py, so activation scripts are not required.
- Healthcheck also uses the venv interpreter.

## Security Notes

- The container runs as a non-root user by default.
- No secrets are stored in the image; use environment variables if needed.
- Avoid mounting sensitive host paths. Restrict X11 permissions with xhost as shown.
