#!/bin/bash
# ========================================================================
# Script Name : lint.sh
# Description : Linux用の Lint 実行スクリプト
# Usage       : ./lint.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "Lint に失敗しました" >&2' ERR

echo "ruff による Lint を実行しています..."
echo

uv run ruff check
echo

echo "Lint が完了しました"
