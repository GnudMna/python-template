#!/usr/bin/env bash
# ========================================================================
# Script Name : lint.sh
# Description : Linux / macOS 用の Lint 実行スクリプト
# Usage       : ./lint.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "Lint に失敗しました" >&2' ERR

echo "ruff による Lint を実行しています..." >&2
echo >&2

uv run ruff check
echo >&2

echo "Lint が完了しました" >&2
