# ========================================================================
# Script Name : run.ps1
# Description : Windows用のアプリ実行スクリプト
# Usage       : ./run.ps1
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    Write-Host 'アプリケーションを実行しています...'
    Write-Host ''

    uv run python-template
    if ($LASTEXITCODE -ne 0) {
        throw "エラー: アプリケーションが終了コード $LASTEXITCODE で失敗しました"
    }
}
