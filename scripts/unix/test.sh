#!/usr/bin/env bash
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

echo "テストを実行しています..." >&2
echo >&2

uv run pytest
echo >&2

echo "すべてのテストが完了しました" >&2
