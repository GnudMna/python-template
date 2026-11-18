# ========================================================================
# Script Name : lint.ps1
# Description : Windows用の Lint 実行スクリプト
# Usage       : ./lint.ps1
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    Write-Host 'ruff による Lint を実行しています...'
    Write-Host ''

    uv run ruff check

    Write-Host ''
    Write-Host 'Lint が完了しました'
}
