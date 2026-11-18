# ========================================================================
# Script Name : test.ps1
# Description : Windows用のテスト実行スクリプト
# Usage       : ./test.ps1
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    [Console]::Error.WriteLine('テストを実行しています...')
    [Console]::Error.WriteLine()

    uv run pytest

    [Console]::Error.WriteLine()
    [Console]::Error.WriteLine('すべてのテストが完了しました')
}
