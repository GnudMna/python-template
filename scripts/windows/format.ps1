# ========================================================================
# Script Name : format.ps1
# Description : Windows用のコード整形スクリプト
# Usage       : ./format.ps1
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    Write-Host 'ruff によるコード整形を実行しています...'
    Write-Host ''

    uv run ruff format
    if ($LASTEXITCODE -ne 0) {
        throw "エラー: ruff format が終了コード $LASTEXITCODE で失敗しました"
    }

    Write-Host ''
    Write-Host 'コード整形が完了しました'
}
