#!/bin/bash
# ========================================================================
# Script Name : check.sh
# Description : macOS用の品質チェックスクリプト(format / lint / typecheck / test)
# Usage       : ./check.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "チェックに失敗しました" >&2' ERR

echo "品質チェックを実行しています..."
echo

echo "依存関係を同期中..."
uv sync
echo

echo "コード整形を検証中..."
uv run ruff format --check
echo

echo "Lint を実行中..."
uv run ruff check
echo

echo "型チェックを実行中..."
uv run pyright
echo

echo "テストを実行中..."
uv run pytest
echo

echo "すべてのチェックが完了しました"
