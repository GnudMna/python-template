#!/usr/bin/env bash
# ========================================================================
# Script Name : build.sh
# Description : Linux / macOS 用のビルド実行スクリプト
# Usage       : ./build.sh
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

trap 'echo "ビルドに失敗しました" >&2' ERR

echo "Python プロジェクトのビルドを実行しています..." >&2
echo >&2

echo "パッケージをビルド中..." >&2
uv build
echo >&2

echo "ビルドが完了しました" >&2
