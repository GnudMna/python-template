#!/bin/bash
# ========================================================================
# Script Name : rename-project.sh
# Description : テンプレートのプロジェクト名を一括変更する
# Usage       : ./rename-project.sh <new-name> [author] [email]
#               new-name : kebab-case(例: my-project)
#               author   : 省略可。LICENSE と pyproject.toml の authors.name を更新
#               email    : 省略可。pyproject.toml の authors.email を更新
# ========================================================================

set -euo pipefail

usage() {
    echo "Usage: $0 <new-name> [author] [email]" >&2
    echo "  new-name : kebab-case(例: my-project)" >&2
    echo "  author   : 省略可 (LICENSE と authors.name を更新(例: \"Your Name\"))" >&2
    echo "  email    : 省略可 (authors.email を更新(例: you@example.com))" >&2
    exit 1
}

[[ $# -lt 1 || $# -gt 3 ]] && usage

NEW_NAME="$1"
AUTHOR="${2:-}"
EMAIL="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../common/cd-project-root.sh
source "$SCRIPT_DIR/../common/cd-project-root.sh"

if [[ ! "$NEW_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    echo "エラー: プロジェクト名は kebab-case で指定してください (例: my-project)" >&2
    exit 1
fi

if [[ "$AUTHOR" == *'"'* || "$EMAIL" == *'"'* ]]; then
    echo "エラー: author / email にダブルクォートは使えません" >&2
    exit 1
fi

if [[ -n "$EMAIL" && "$EMAIL" != *@* ]]; then
    echo "エラー: email の形式が正しくありません" >&2
    exit 1
fi

escape_sed_repl() {
    printf '%s' "$1" | sed -e 's/[&/\]/\\&/g'
}

replace_in_file() {
    local file="$1"
    local from="$2"
    local to="$3"
    [[ -f "$file" ]] || return 0
    sed -i '' "s/${from}/${to}/g" "$file"
}

replace_name_in_file() {
    replace_in_file "$1" "$CURRENT_NAME" "$NEW_NAME"
    replace_in_file "$1" "$OLD_IDENT" "$NEW_IDENT"
}

CURRENT_NAME="$(grep -E '^name = ' pyproject.toml | head -1 | sed -E 's/^name = "(.*)"/\1/')"
NEW_IDENT="${NEW_NAME//-/_}"
OLD_IDENT="${CURRENT_NAME//-/_}"

NAME_UNCHANGED=false
if [[ "$CURRENT_NAME" == "$NEW_NAME" ]]; then
    NAME_UNCHANGED=true
    if [[ -z "$AUTHOR" && -z "$EMAIL" ]]; then
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
    sed -i '' "s/^${CURRENT_NAME} = \"${OLD_IDENT}.cli:main\"/${NEW_NAME} = \"${NEW_IDENT}.cli:main\"/" pyproject.toml

    replace_name_in_file "${NEW_PACKAGE_DIR}/__init__.py"
    for test_file in tests/*.py; do
        [[ -f "$test_file" ]] || continue
        sed -i '' "s/from ${OLD_IDENT}/from ${NEW_IDENT}/g" "$test_file"
    done
    replace_name_in_file README.md
    replace_name_in_file .vscode/launch.json
    replace_name_in_file scripts/linux/run.sh
    replace_name_in_file scripts/macos/run.sh
    replace_name_in_file scripts/windows/run.ps1
fi

if [[ -n "$AUTHOR" ]]; then
    if [[ "$NAME_UNCHANGED" == true ]]; then
        echo "著作権者と authors を \"${AUTHOR}\" に更新しています..."
        echo
    fi

    AUTHOR_REPL="$(escape_sed_repl "$AUTHOR")"
    YEAR="$(date +%Y)"
    COPYRIGHT_LINE="Copyright (c) ${YEAR} ${AUTHOR_REPL}"
    sed -i '' "s/^Copyright (c) .*/${COPYRIGHT_LINE}/" LICENSE
    sed -i '' -E "s/(\{ name = \")[^\"]+(\", email =)/\1${AUTHOR_REPL}\2/" pyproject.toml
fi

if [[ -n "$EMAIL" ]]; then
    EMAIL_REPL="$(escape_sed_repl "$EMAIL")"
    sed -i '' -E "s/(\{ name = \"[^\"]+\", email = \")[^\"]+(\")/\1${EMAIL_REPL}\2/" pyproject.toml
fi

if [[ "$NAME_UNCHANGED" == false ]]; then
    echo "uv.lock を更新しています..."
    uv lock
    echo
fi

echo "変更が完了しました。必要に応じて以下を手動で更新してください:"
echo "  - pyproject.toml の description, repository"
echo "  - README.md のプロジェクト説明文"
if [[ -z "$AUTHOR" ]]; then
    echo "  - LICENSE の著作権表記と pyproject.toml の authors.name (または author を指定して再実行)"
fi
if [[ -z "$EMAIL" ]]; then
    echo "  - pyproject.toml の authors.email (または email を指定して再実行)"
fi
