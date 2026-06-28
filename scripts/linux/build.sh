#!/bin/bash
# ========================================================================
# Script Name : build.sh
# Description : Linux用のビルド実行スクリプト
# Usage       : ./build.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "ビルドに失敗しました" >&2' ERR

echo "Python プロジェクトのビルドを実行しています..."
echo

echo "依存関係を同期中..."
uv sync
echo

echo "パッケージをビルド中..."
uv build
echo

echo "ビルドが完了しました"
