#!/bin/bash
# ========================================================================
# Script Name : rename-project.sh
# Description : テンプレートのプロジェクト名を一括変更する
# Usage       : ./rename-project.sh <new-name> [copyright-holder]
#               new-name         : kebab-case(例: my-project)
#               copyright-holder : 省略可(例: "Your Name")
# ========================================================================

set -euo pipefail

usage() {
    echo "Usage: $0 <new-name> [copyright-holder]" >&2
    echo "  new-name         : kebab-case(例: my-project)" >&2
    echo "  copyright-holder : 省略可 (LICENSE を更新(例: \"Your Name\"))" >&2
    exit 1
}

[[ $# -lt 1 || $# -gt 2 ]] && usage

NEW_NAME="$1"
COPYRIGHT_HOLDER="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

if [[ ! "$NEW_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    echo "エラー: プロジェクト名は kebab-case で指定してください (例: my-project)" >&2
    exit 1
fi

CURRENT_NAME="$(grep -E '^name = ' pyproject.toml | head -1 | sed -E 's/^name = "(.*)"/\1/')"
NEW_IDENT="${NEW_NAME//-/_}"
OLD_IDENT="${CURRENT_NAME//-/_}"

NAME_UNCHANGED=false
if [[ "$CURRENT_NAME" == "$NEW_NAME" ]]; then
    NAME_UNCHANGED=true
    if [[ -z "$COPYRIGHT_HOLDER" ]]; then
        echo "プロジェクト名は既に \"${NEW_NAME}\" です"
        exit 0
    fi
fi

if [[ "$NAME_UNCHANGED" == false ]]; then
    echo "プロジェクト名を \"${CURRENT_NAME}\" から \"${NEW_NAME}\" に変更しています..."
    echo

    OLD_PACKAGE_DIR="src/${OLD_IDENT}"
    NEW_PACKAGE_DIR="src/${NEW_IDENT}"
    if [[ ! -d "$OLD_PACKAGE_DIR" ]]; then
        echo "エラー: パッケージディレクトリが見つかりません: ${OLD_PACKAGE_DIR}" >&2
        exit 1
    fi
    if [[ -d "$NEW_PACKAGE_DIR" ]]; then
        echo "エラー: 移動先のパッケージディレクトリが既に存在します: ${NEW_PACKAGE_DIR}" >&2
        exit 1
    fi

    mv "$OLD_PACKAGE_DIR" "$NEW_PACKAGE_DIR"

    sed -i '' "s/^name = \"${CURRENT_NAME}\"/name = \"${NEW_NAME}\"/" pyproject.toml
    sed -i '' "s/^${CURRENT_NAME} = \"${OLD_IDENT}:main\"/${NEW_NAME} = \"${NEW_IDENT}:main\"/" pyproject.toml

    sed -i '' "s/\`${CURRENT_NAME}\`/\`${NEW_NAME}\`/g" "${NEW_PACKAGE_DIR}/__init__.py"
    sed -i '' "s/from ${OLD_IDENT} import/from ${NEW_IDENT} import/g" tests/test_greet.py
fi

if [[ -n "$COPYRIGHT_HOLDER" ]]; then
    if [[ "$NAME_UNCHANGED" == true ]]; then
        echo "著作権者を \"${COPYRIGHT_HOLDER}\" に更新しています..."
        echo
    fi

    COPYRIGHT_LINE="Copyright (c) 2026 ${COPYRIGHT_HOLDER}"
    sed -i '' "s/^Copyright (c) .*/${COPYRIGHT_LINE}/" LICENSE
fi

echo "uv.lock を更新しています..."
uv lock
echo

echo "変更が完了しました。必要に応じて以下を手動で更新してください:"
echo "  - pyproject.toml の description, authors, repository"
echo "  - README.md のタイトル"
if [[ -z "$COPYRIGHT_HOLDER" ]]; then
    echo "  - LICENSE の著作権表記(または copyright-holder を指定して再実行)"
fi
