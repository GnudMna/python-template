"""コマンドラインインターフェース"""

import argparse
from dataclasses import dataclass

from .greet import greet


@dataclass(frozen=True, slots=True)
class Args:
    """解析済みのコマンドライン引数

    Parameters
    ----------
    name : str
        挨拶する名前
    count : int
        挨拶する回数
    """

    name: str
    count: int


def _positive_int(value: str) -> int:
    """正の整数に変換する

    Parameters
    ----------
    value : str
        変換する文字列

    Returns
    -------
    int
        1 以上の整数

    Raises
    ------
    ValueError
        整数に変換できない場合。argparse がエラー表示に使う。
    argparse.ArgumentTypeError
        1 未満の場合
    """
    parsed = int(value)
    if parsed < 1:
        raise argparse.ArgumentTypeError(f"{value} is not a positive integer")
    return parsed


def parse_args(argv: list[str] | None = None) -> Args:
    """引数を解析する

    Parameters
    ----------
    argv : list[str] | None, optional
        コマンドライン引数, デフォルトは None

    Returns
    -------
    Args
        解析された引数
    """
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
        type=_positive_int,
        default=1,
        help="Number of times to greet (default: 1)",
    )
    parsed = parser.parse_args(argv)
    return Args(name=parsed.name, count=parsed.count)


def main(argv: list[str] | None = None) -> int:
    """メイン関数

    Parameters
    ----------
    argv : list[str] | None, optional
        コマンドライン引数, デフォルトは None

    Returns
    -------
    int
        終了コード。成功時は 0
    """
    args = parse_args(argv)
    for _ in range(args.count):
        print(greet(args.name))
    return 0
