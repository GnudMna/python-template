"""テンプレートのプロジェクト名を一括変更する (標準ライブラリのみ)。

scripts/unix/rename-project.sh と scripts/windows/rename-project.ps1 から呼ばれる。
"""

import argparse
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

NAME_PATTERN = re.compile(r"[a-z][a-z0-9]*(-[a-z0-9]+)*")
CURRENT_NAME_PATTERN = re.compile(r'^name = "([^"]+)"', re.MULTILINE)
AUTHOR_PATTERN = re.compile(r'(\{ name = ")[^"]+(", email =)')
EMAIL_PATTERN = re.compile(r'(\{ name = "[^"]+", email = ")[^"]+(")')
COPYRIGHT_PATTERN = re.compile(r"^Copyright \(c\) .*", re.MULTILINE)

# 名前を置換するファイル。プロジェクトルートからの相対パスで指定する
RENAME_TARGETS = (
    "README.md",
    ".vscode/launch.json",
    "scripts/unix/run.sh",
    "scripts/windows/run.ps1",
)


class RenameError(Exception):
    """利用者に伝えるべき入力・状態のエラー。"""


def read_text(path: Path) -> str:
    """改行を変換せずに UTF-8 で読み込む。"""
    return path.read_bytes().decode("utf-8")


def write_text(path: Path, value: str) -> None:
    """改行を変換せずに UTF-8 (BOM なし) で書き込む。"""
    path.write_bytes(value.encode("utf-8"))


def replace_word(text: str, old: str, new: str) -> str:
    """識別子の一部 (pytest, tests/ など) を巻き込まないよう、単語境界つきで置換する。"""
    pattern = r"(?<![A-Za-z0-9_-])" + re.escape(old) + r"(?![A-Za-z0-9_-])"
    return re.sub(pattern, lambda _: new, text)


def update_file(path: Path, replacements: list[tuple[str, str]]) -> None:
    """存在するファイルにだけ単語境界つき置換を適用し、変化があれば書き戻す。"""
    if not path.is_file():
        return
    content = read_text(path)
    updated = content
    for old, new in replacements:
        updated = replace_word(updated, old, new)
    if updated != content:
        write_text(path, updated)


def parse_args() -> argparse.Namespace:
    """コマンドライン引数を解釈する。"""
    parser = argparse.ArgumentParser(
        description="テンプレートのプロジェクト名を一括変更する",
    )
    parser.add_argument("new_name", metavar="new-name", help="kebab-case (例: my-project)")
    parser.add_argument(
        "author",
        nargs="?",
        default="",
        help='省略可。LICENSE と authors.name を更新 (例: "Your Name")',
    )
    parser.add_argument(
        "email",
        nargs="?",
        default="",
        help="省略可。authors.email を更新 (例: you@example.com)",
    )
    return parser.parse_args()


def validate(new_name: str, author: str, email: str) -> None:
    """入力値を検証する。"""
    if not NAME_PATTERN.fullmatch(new_name):
        msg = "プロジェクト名は kebab-case で指定してください (例: my-project)"
        raise RenameError(msg)
    if '"' in author or '"' in email:
        msg = "author / email にダブルクォートは使えません"
        raise RenameError(msg)
    if email and "@" not in email:
        msg = "email の形式が正しくありません"
        raise RenameError(msg)


def rename_package(current_name: str, new_name: str, pyproject: str) -> str:
    """パッケージディレクトリと関連ファイルの名前を置換し、更新後の pyproject.toml を返す。"""
    old_ident = current_name.replace("-", "_")
    new_ident = new_name.replace("-", "_")

    old_dir = PROJECT_ROOT / "src" / old_ident
    new_dir = PROJECT_ROOT / "src" / new_ident
    if not old_dir.is_dir():
        msg = f"パッケージディレクトリが見つかりません: {old_dir}"
        raise RenameError(msg)
    if new_dir.exists():
        msg = f"移動先のパッケージディレクトリが既に存在します: {new_dir}"
        raise RenameError(msg)

    old_dir.rename(new_dir)

    pyproject = re.sub(
        rf'^name = "{re.escape(current_name)}"',
        lambda _: f'name = "{new_name}"',
        pyproject,
        flags=re.MULTILINE,
    )
    pyproject = re.sub(
        rf'^{re.escape(current_name)} = "{re.escape(old_ident)}\.cli:main"$',
        lambda _: f'{new_name} = "{new_ident}.cli:main"',
        pyproject,
        flags=re.MULTILINE,
    )

    name_replacements = [(current_name, new_name), (old_ident, new_ident)]
    update_file(new_dir / "__init__.py", name_replacements)
    for test_file in sorted((PROJECT_ROOT / "tests").glob("*.py")):
        update_file(test_file, [(f"from {old_ident}", f"from {new_ident}")])
    for relative_path in RENAME_TARGETS:
        update_file(PROJECT_ROOT / relative_path, name_replacements)

    return pyproject


def update_author(author: str, pyproject: str) -> str:
    """LICENSE の著作権表記と authors.name を更新し、更新後の pyproject.toml を返す。"""
    copyright_line = f"Copyright (c) {datetime.now().year} {author}"  # noqa: DTZ005
    license_path = PROJECT_ROOT / "LICENSE"
    license_text = read_text(license_path)
    write_text(
        license_path,
        COPYRIGHT_PATTERN.sub(lambda _: copyright_line, license_text),
    )
    toml_author = author.replace("\\", "\\\\")  # TOML の基本文字列用にエスケープ
    return AUTHOR_PATTERN.sub(lambda m: m[1] + toml_author + m[2], pyproject)


def update_email(email: str, pyproject: str) -> str:
    """authors.email を更新し、更新後の pyproject.toml を返す。"""
    toml_email = email.replace("\\", "\\\\")
    return EMAIL_PATTERN.sub(lambda m: m[1] + toml_email + m[2], pyproject)


def run(new_name: str, author: str, email: str) -> None:
    """リネーム処理の本体。"""
    validate(new_name, author, email)

    pyproject_path = PROJECT_ROOT / "pyproject.toml"
    pyproject = read_text(pyproject_path)
    match = CURRENT_NAME_PATTERN.search(pyproject)
    if match is None:
        msg = "pyproject.toml から name を読み取れません"
        raise RenameError(msg)
    current_name = match[1]

    name_unchanged = current_name == new_name
    if name_unchanged and not author and not email:
        print(f'プロジェクト名は既に "{new_name}" です')
        return

    if name_unchanged:
        if author:
            print(f'著作権者と authors を "{author}" に更新しています...\n')
    else:
        print(f'プロジェクト名を "{current_name}" から "{new_name}" に変更しています...\n')
        pyproject = rename_package(current_name, new_name, pyproject)

    if author:
        pyproject = update_author(author, pyproject)
    if email:
        pyproject = update_email(email, pyproject)
    write_text(pyproject_path, pyproject)

    if not name_unchanged:
        print("uv.lock を更新しています...")
        result = subprocess.run(["uv", "lock"], cwd=PROJECT_ROOT, check=False)  # noqa: S607
        if result.returncode != 0:
            msg = f"uv lock が終了コード {result.returncode} で失敗しました"
            raise RenameError(msg)
        print()

    print("変更が完了しました。必要に応じて以下を手動で更新してください:")
    print("  - pyproject.toml の description, repository")
    print("  - README.md のプロジェクト説明文")
    if not author:
        print("  - LICENSE の著作権表記と pyproject.toml の authors.name")
        print("    (または author を指定して再実行)")
    if not email:
        print("  - pyproject.toml の authors.email (または email を指定して再実行)")


def main() -> int:
    """エントリポイント。成功なら 0、入力・状態のエラーなら 1 を返す。"""
    args = parse_args()
    try:
        run(args.new_name, args.author, args.email)
    except RenameError as error:
        print(f"エラー: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
