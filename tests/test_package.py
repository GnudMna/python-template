"""パッケージメタデータと型情報マーカーのテスト"""

from importlib.metadata import version
from importlib.resources import files

from python_template import __version__

PACKAGE_NAME = "python_template"
DIST_NAME = "python-template"


def test_version_matches_installed_metadata() -> None:
    """__version__ がインストール済み配布物の version と一致することを検証する"""
    assert __version__ == version(DIST_NAME)


def test_py_typed_marker_exists() -> None:
    """PEP 561 の py.typed がパッケージディレクトリにあることを検証する"""
    assert files(PACKAGE_NAME).joinpath("py.typed").is_file()
