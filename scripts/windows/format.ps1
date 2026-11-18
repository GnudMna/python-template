# ========================================================================
# Script Name : format.ps1
# Description : Windows用のコード整形スクリプト
# Usage       : ./format.ps1
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    Write-Host 'ruff によるコード整形を実行しています...'
    Write-Host ''

    uv run ruff format

    Write-Host ''
    Write-Host 'コード整形が完了しました'
}
