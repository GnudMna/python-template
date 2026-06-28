#!/bin/bash
# ========================================================================
# Script Name : format.sh
# Description : Linux用のコード整形スクリプト
# Usage       : ./format.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "コード整形に失敗しました" >&2' ERR

echo "ruff によるコード整形を実行しています..."
echo

uv run ruff format
echo

echo "コード整形が完了しました"
