#!/usr/bin/env bash
# ========================================================================
# Script Name : rename-project.sh
# Description : テンプレートのプロジェクト名を一括変更する (Linux / macOS)
#               処理本体は scripts/rename_project.py
# Usage       : ./rename-project.sh <new-name> [author] [email]
#               new-name : kebab-case(例: my-project)
#               author   : 省略可。LICENSE と pyproject.toml の authors.name を更新
#               email    : 省略可。pyproject.toml の authors.email を更新
# ========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

exec uv run --no-project python scripts/rename_project.py "$@"
