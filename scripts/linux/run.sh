#!/bin/bash
# ========================================================================
# Script Name : run.sh
# Description : Linux用のアプリ実行スクリプト
# Usage       : ./run.sh [args...]
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "実行に失敗しました" >&2' ERR

echo "アプリケーションを実行しています..."
echo

uv run python-template "$@"
