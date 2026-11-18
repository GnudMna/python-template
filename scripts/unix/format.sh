#!/usr/bin/env bash
# ========================================================================
# Script Name : format.sh
# Description : Linux / macOS 用のコード整形スクリプト
# Usage       : ./format.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "コード整形に失敗しました" >&2' ERR

echo "ruff によるコード整形を実行しています..." >&2
echo >&2

uv run ruff format
echo >&2

echo "コード整形が完了しました" >&2
