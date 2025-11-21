# syntax=docker/dockerfile:1
# Base image with Python for running Tkinter applications
FROM python:3.11-slim

# Set environment variables for Python behavior
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies needed for Tkinter (tk, tcl) and basic tools
# Also install locales to avoid runtime warnings in some environments
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tk \
        tcl \
        locales \
        ca-certificates \
        build-essential \
        # Optional: useful for debugging inside the container
        procps \
        nano \
    && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Create a non-root user to run the app securely
ARG USERNAME=appuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}

# Set working directory
WORKDIR /app

# Copy application files (if present). We copy the whole context to /app
# For security, avoid copying unnecessary Docker-related files.
COPY . /app

# If the project includes Python dependencies, uncomment the following lines and
# ensure a requirements.txt exists.
# RUN python -m pip install --upgrade pip setuptools wheel
# COPY requirements.txt /app/requirements.txt
# RUN pip install --no-cache-dir -r /app/requirements.txt

# Ensure entrypoint script is executable if present
# We will default to running app.py. If the app uses a different entry, update CMD.
# Use a basic healthcheck to ensure the container stays responsive.
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD python -c "import sys" || exit 1

# Change ownership of the app directory
RUN chown -R ${USERNAME}:${USERNAME} /app

# Switch to non-root user
USER ${USERNAME}

# Expose no ports as this is a native GUI app. Running GUI apps in Docker generally
# requires X11 or Wayland forwarding, or using xvfb for headless mode.
# For generalization, we keep the CMD minimal. Users can override at runtime.
# PUBLIC_INTERFACE
# Entry point for running the Tkinter clock (expects app.py present)
CMD ["python", "app.py"]
