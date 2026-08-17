"""CLI の引数解析・実行・失敗系のテスト"""

import pytest

from python_template.cli import main, parse_args


def test_parse_args_defaults() -> None:
    """引数なしのときのデフォルト値を検証する"""
    args = parse_args([])
    assert args.name == "world"
    assert args.count == 1


def test_parse_args_name_and_long_count() -> None:
    """位置引数と長いオプション --count を検証する"""
    args = parse_args(["Alice", "--count", "3"])
    assert args.name == "Alice"
    assert args.count == 3


def test_parse_args_short_count() -> None:
    """短縮オプション -n が --count と同じ意味になることを検証する"""
    args = parse_args(["Bob", "-n", "2"])
    assert args.name == "Bob"
    assert args.count == 2


@pytest.mark.parametrize(
    ("argv", "expected"),
    [
        ([], "Hello, world!\n"),
        (["Alice"], "Hello, Alice!\n"),
        (["Alice", "--count", "2"], "Hello, Alice!\nHello, Alice!\n"),
        (["Bob", "-n", "3"], "Hello, Bob!\nHello, Bob!\nHello, Bob!\n"),
    ],
)
def test_main_prints_greetings(
    argv: list[str],
    expected: str,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """main が標準出力へ挨拶を書き出すことを検証する

    Parameters
    ----------
    argv : list[str]
        コマンドライン引数
    expected : str
        期待する標準出力
    capsys : pytest.CaptureFixture[str]
        標準出力を捕捉するフィクスチャ
    """
    main(argv)
    assert capsys.readouterr().out == expected


def test_main_help_exits_zero(capsys: pytest.CaptureFixture[str]) -> None:
    """--help が終了コード 0 で使い方を表示することを検証する

    Parameters
    ----------
    capsys : pytest.CaptureFixture[str]
        標準出力を捕捉するフィクスチャ
    """
    with pytest.raises(SystemExit) as exc_info:
        main(["--help"])

    assert exc_info.value.code == 0
    output = capsys.readouterr().out
    assert "Greet someone" in output
    assert "--count" in output


@pytest.mark.parametrize("count", ["0", "-1", "abc"])
def test_main_rejects_invalid_count(
    count: str,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """不正な --count が終了コード 2 で拒否されることを検証する

    Parameters
    ----------
    count : str
        不正な回数指定 (0 / 負数 / 非整数)
    capsys : pytest.CaptureFixture[str]
        標準エラー出力を捕捉するフィクスチャ
    """
    with pytest.raises(SystemExit) as exc_info:
        main(["--count", count])

    assert exc_info.value.code == 2
    assert "error:" in capsys.readouterr().err
