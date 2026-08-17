"""`python-template` 用のライブラリパッケージ"""

from importlib.metadata import PackageNotFoundError, version

from .greet import greet

try:
    __version__ = version("python-template")
except PackageNotFoundError:
    __version__ = "0.0.0"

__all__ = ["__version__", "greet"]
