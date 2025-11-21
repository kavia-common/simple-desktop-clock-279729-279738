#!/usr/bin/env python3
"""
A simple Tkinter-based desktop clock.
This file serves as the default entrypoint for the Docker image.
"""

import logging
import sys
import time
from datetime import datetime
from typing import Optional

try:
    import tkinter as tk
    from tkinter import ttk
except Exception as exc:  # noqa: BLE001
    # Log the error and exit gracefully if Tkinter is not available.
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        stream=sys.stdout,
    )
    logging.error("Failed to import Tkinter: %s", exc)
    sys.exit(1)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    stream=sys.stdout,
)

# PUBLIC_INTERFACE
def run_clock() -> None:
    """Run the Tkinter clock application."""
    root: tk.Tk = tk.Tk()
    root.title("Simple Desktop Clock")

    # Create a main frame with padding
    main: ttk.Frame = ttk.Frame(root, padding="16 16 16 16")
    main.grid(column=0, row=0, sticky="nsew")

    root.columnconfigure(0, weight=1)
    root.rowconfigure(0, weight=1)

    # Create label to display time
    time_var: tk.StringVar = tk.StringVar(value="--:--:--")
    time_label: ttk.Label = ttk.Label(
        main,
        textvariable=time_var,
        font=("Helvetica", 36, "bold"),
        foreground="#2563EB",
    )
    time_label.grid(column=0, row=0, padx=8, pady=8)

    # Update the time every 200 ms
    def update_time() -> None:
        try:
            time_var.set(datetime.now().strftime("%H:%M:%S"))
        except Exception as e:  # noqa: BLE001
            logging.error("Error while updating time: %s", e)
        finally:
            # Schedule the next update
            root.after(200, update_time)

    # Start updating time and Tk main loop
    root.after(0, update_time)

    # Attempt to center window on screen
    try:
        root.update_idletasks()
        w: int = root.winfo_width()
        h: int = root.winfo_height()
        x: int = (root.winfo_screenwidth() // 2) - (w // 2)
        y: int = (root.winfo_screenheight() // 2) - (h // 2)
        root.geometry(f"+{x}+{y}")
    except Exception as e:  # noqa: BLE001
        logging.info("Unable to center window: %s", e)

    logging.info("Starting Tkinter clock UI.")
    root.mainloop()


if __name__ == "__main__":
    try:
        run_clock()
    except KeyboardInterrupt:
        logging.info("Received KeyboardInterrupt, exiting.")
    except Exception as e:  # noqa: BLE001
        logging.error("Unexpected error: %s", e)
        sys.exit(1)
