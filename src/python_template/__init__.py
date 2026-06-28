"""Library package for `python-template`."""


def greet(name: str) -> str:
    """Return a greeting message for the given name."""
    return f"Hello, {name}!"


def main() -> None:
    """Entry point for the console script."""
    print(greet("world"))
