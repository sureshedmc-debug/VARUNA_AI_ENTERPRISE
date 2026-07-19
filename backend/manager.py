#!/usr/bin/env python3
"""VARUNA AI Enterprise – CLI entry point.

Starts the uvicorn ASGI server with the FastAPI application.

Usage
-----
::

    python manager.py [--host HOST] [--port PORT] [--reload]

Or run directly with uvicorn::

    uvicorn app.main:app --host 0.0.0.0 --port 8000

Environment variables (prefix ``VARUNA_``) or a ``.env`` file can be used
to configure the application without modifying this file.
"""

from __future__ import annotations

import argparse
import logging
import sys

import uvicorn

from app.config import settings

logger = logging.getLogger("varuna.manager")


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="VARUNA AI Enterprise backend server",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--host",
        default=settings.host,
        help="Bind address",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=settings.port,
        help="TCP port",
    )
    parser.add_argument(
        "--reload",
        action="store_true",
        default=settings.debug,
        help="Enable auto-reload (development only)",
    )
    parser.add_argument(
        "--log-level",
        default="debug" if settings.debug else "info",
        choices=["critical", "error", "warning", "info", "debug", "trace"],
        help="Uvicorn log level",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
    args = parse_args(argv)

    logging.basicConfig(
        level=logging.DEBUG if args.log_level in ("debug", "trace") else logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    logger.info(
        "Starting VARUNA AI Enterprise backend on %s:%d (reload=%s)",
        args.host,
        args.port,
        args.reload,
    )

    uvicorn.run(
        "app.main:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
        log_level=args.log_level,
        access_log=True,
    )


if __name__ == "__main__":
    main(sys.argv[1:])
