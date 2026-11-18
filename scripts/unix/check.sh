#!/usr/bin/env bash
# ========================================================================
# Script Name : check.sh
# Description : Linux / macOS 用の品質チェックスクリプト(format / lint / typecheck / test)
# Usage       : ./check.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "チェックに失敗しました" >&2' ERR

echo "品質チェックを実行しています..." >&2
echo >&2

echo "依存関係を同期中..." >&2
uv sync --locked
echo >&2

echo "コード整形を検証中..." >&2
uv run ruff format --check
echo >&2

echo "Lint を実行中..." >&2
uv run ruff check
echo >&2

echo "型チェックを実行中..." >&2
uv run pyright
echo >&2

echo "テストを実行中..." >&2
uv run pytest
echo >&2

echo "すべてのチェックが完了しました" >&2
