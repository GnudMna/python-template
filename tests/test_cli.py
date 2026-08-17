import pytest

from python_template.cli import main


def test_main_default(capsys: pytest.CaptureFixture[str]) -> None:
    main([])
    assert capsys.readouterr().out == "Hello, world!\n"


def test_main_with_name(capsys: pytest.CaptureFixture[str]) -> None:
    main(["Alice"])
    assert capsys.readouterr().out == "Hello, Alice!\n"


def test_main_with_count(capsys: pytest.CaptureFixture[str]) -> None:
    main(["Alice", "--count", "2"])
    assert capsys.readouterr().out == "Hello, Alice!\nHello, Alice!\n"
