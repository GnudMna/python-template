# ========================================================================
# Script Name : check.ps1
# Description : Windows用の品質チェックスクリプト(format / lint / typecheck / test)
# Usage       : ./check.ps1
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    [Console]::Error.WriteLine('品質チェックを実行しています...')
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('依存関係を同期中...')
    uv sync --locked
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('コード整形を検証中...')
    uv run ruff format --check
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('Lint を実行中...')
    uv run ruff check
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('型チェックを実行中...')
    uv run pyright
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('テストを実行中...')
    uv run pytest
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('すべてのチェックが完了しました')
}
