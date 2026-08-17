"""Command-line interface."""

import argparse

from .greet import greet


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Greet someone.")
    parser.add_argument(
        "name",
        nargs="?",
        default="world",
        help="Name to greet (default: world)",
    )
    parser.add_argument(
        "-n",
        "--count",
        type=int,
        default=1,
        help="Number of times to greet (default: 1)",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
    """Entry point for the console script."""
    args = parse_args(argv)
    for _ in range(args.count):
        print(greet(args.name))
