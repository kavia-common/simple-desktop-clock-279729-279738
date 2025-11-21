# Tkinter Native App - Simple Desktop Clock

This container provides a simple Tkinter-based clock. It includes a Dockerfile and build script fixed to avoid bash syntax errors and to support GUI execution via X11 on Linux.

## Build

- Using the helper script:
  ./build.sh
  Optionally set IMAGE_NAME before building:
  IMAGE_NAME=myorg/tkinter_native_app:latest ./build.sh

- Using raw docker:
  docker build -t tkinter_native_app:latest .

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

  docker run --rm tkinter_native_app:latest bash -lc "xvfb-run -a python app.py"

Note: xvfb is not installed in the image by default to keep the image slim. You can extend the Dockerfile or install at runtime if needed.

## Security Notes

- The container runs as a non-root user by default.
- No secrets are stored in the image; use environment variables if needed.
- Avoid mounting sensitive host paths. Restrict X11 permissions with xhost as shown.
