# ========================================================================
# Script Name : build.ps1
# Description : Windows用のビルド実行スクリプト
# Usage       : ./build.ps1
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    [Console]::Error.WriteLine('Python プロジェクトのビルドを実行しています...')
    [Console]::Error.WriteLine()

    [Console]::Error.WriteLine('パッケージをビルド中...')
    uv build

    [Console]::Error.WriteLine()
    [Console]::Error.WriteLine('ビルドが完了しました')
}
