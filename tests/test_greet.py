"""ライブラリ関数 greet の単体テスト"""

import pytest

from python_template import greet


@pytest.mark.parametrize(
    ("name", "expected"),
    [
        ("world", "Hello, world!"),
        ("Alice", "Hello, Alice!"),
        ("太郎", "Hello, 太郎!"),
        ("", "Hello, !"),
    ],
)
def test_greet_returns_expected_message(name: str, expected: str) -> None:
    """挨拶メッセージが入力に応じて生成されることを検証する

    Parameters
    ----------
    name : str
        挨拶する名前
    expected : str
        期待するメッセージ
    """
    assert greet(name) == expected
