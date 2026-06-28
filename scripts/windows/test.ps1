# ========================================================================
# Script Name : test.ps1
# Description : Windows用のテスト実行スクリプト
# Usage       : ./test.ps1
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    Write-Host 'テストを実行しています...'
    Write-Host ''

    uv run pytest
    if ($LASTEXITCODE -ne 0) {
        throw "エラー: pytest が終了コード $LASTEXITCODE で失敗しました"
    }

    Write-Host ''
    Write-Host 'すべてのテストが完了しました'
}
