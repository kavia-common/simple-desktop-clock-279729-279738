# syntax=docker/dockerfile:1
# Base image with Python for running Tkinter applications
FROM python:3.11-slim

# Set environment variables for Python behavior and venv
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}"

# Install system dependencies needed for Tkinter (tk, tcl) and basic tools
# Also install locales to avoid runtime warnings in some environments
# Explicitly install python3-venv and python3-pip to ensure pip availability even if ensurepip is minimal.
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        tk \
        tcl \
        locales \
        ca-certificates \
        build-essential \
        python3-venv \
        python3-pip \
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

# Create a virtual environment in /opt/venv and ensure pip exists
# Use POSIX-compatible shell commands without relying on 'source' for non-interactive shells.
RUN python3 -m venv "${VIRTUAL_ENV}" || python -m venv "${VIRTUAL_ENV}" && \
    # Bootstrap pip inside the venv in case it's missing
    ("${VIRTUAL_ENV}/bin/python" -m ensurepip --upgrade || true) && \
    # Upgrade pip/setuptools/wheel defensively
    "${VIRTUAL_ENV}/bin/python" -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Create a non-root user to run the app securely
ARG USERNAME=appuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}"

# Set working directory
WORKDIR /app

# Copy application files
COPY . /app

# Install Python dependencies if requirements.txt exists
# This block handles the case where requirements.txt is missing gracefully.
RUN if [ -f "/app/requirements.txt" ]; then \
        echo "[INFO] Installing dependencies from requirements.txt"; \
        "${VIRTUAL_ENV}/bin/python" -m pip install --no-cache-dir -r /app/requirements.txt; \
    else \
        echo "[INFO] No requirements.txt found. Skipping dependency installation."; \
    fi

# Use a basic healthcheck to ensure the container stays responsive.
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD "${VIRTUAL_ENV}/bin/python" -c "import sys" || exit 1

# Change ownership of the app directory
RUN chown -R "${USERNAME}:${USERNAME}" /app

# Switch to non-root user
USER ${USERNAME}

# PUBLIC_INTERFACE
# Entry point for running the Tkinter clock using the venv's Python (expects app.py present)
# Avoid relying on 'source' and call interpreter directly to ensure venv is used.
CMD ["/opt/venv/bin/python", "app.py"]
