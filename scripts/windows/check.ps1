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

    Write-Host '品質チェックを実行しています...'
    Write-Host ''

    Write-Host '依存関係を同期中...'
    uv sync
    Write-Host ''

    Write-Host 'コード整形を検証中...'
    uv run ruff format --check
    Write-Host ''

    Write-Host 'Lint を実行中...'
    uv run ruff check
    Write-Host ''

    Write-Host '型チェックを実行中...'
    uv run pyright
    Write-Host ''

    Write-Host 'テストを実行中...'
    uv run pytest
    Write-Host ''

    Write-Host 'すべてのチェックが完了しました'
}
