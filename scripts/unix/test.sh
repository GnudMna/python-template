#!/bin/bash
# ========================================================================
# Script Name : test.sh
# Description : Linux / macOS 用のテスト実行スクリプト
# Usage       : ./test.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "テストに失敗しました" >&2' ERR

echo "テストを実行しています..."
echo

uv run pytest
echo

echo "すべてのテストが完了しました"
