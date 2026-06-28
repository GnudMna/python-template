from python_template import greet


def test_greet_returns_expected_message() -> None:
    assert greet("world") == "Hello, world!"


def test_greet_integration() -> None:
    assert greet("integration") == "Hello, integration!"
