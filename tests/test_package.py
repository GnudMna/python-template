"""パッケージメタデータと型情報マーカーのテスト"""

from importlib.metadata import version
from pathlib import Path

from python_template import __version__
from python_template.greet import greet


def test_version_matches_installed_metadata() -> None:
    """__version__ がインストール済み配布物の version と一致することを検証する"""
    dist_name = Path(greet.__code__.co_filename).parent.name.replace("_", "-")
    assert __version__ == version(dist_name)


def test_py_typed_marker_exists() -> None:
    """PEP 561 の py.typed がパッケージディレクトリにあることを検証する"""
    package_dir = Path(greet.__code__.co_filename).parent
    assert (package_dir / "py.typed").is_file()
