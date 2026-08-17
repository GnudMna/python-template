"""コマンドラインインターフェース"""

import argparse

from .greet import greet


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """引数を解析する

    Parameters
    ----------
    argv : list[str] | None, optional
        コマンドライン引数, デフォルトは None

    Returns
    -------
    argparse.Namespace
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
        type=int,
        default=1,
        help="Number of times to greet (default: 1)",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
    """メイン関数

    Parameters
    ----------
    argv : list[str] | None, optional
        コマンドライン引数, デフォルトは None
    """
    args = parse_args(argv)
    for _ in range(args.count):
        print(greet(args.name))
