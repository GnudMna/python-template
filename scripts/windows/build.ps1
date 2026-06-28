# ========================================================================
# Script Name : build.ps1
# Description : Windows用のビルド実行スクリプト
# Usage       : ./build.ps1
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    Write-Host 'Python プロジェクトのビルドを実行しています...'
    Write-Host ''

    Write-Host '依存関係を同期中...'
    uv sync
    if ($LASTEXITCODE -ne 0) {
        throw "エラー: uv sync が終了コード $LASTEXITCODE で失敗しました"
    }
    Write-Host ''

    Write-Host 'パッケージをビルド中...'
    uv build
    if ($LASTEXITCODE -ne 0) {
        throw "エラー: uv build が終了コード $LASTEXITCODE で失敗しました"
    }

    Write-Host ''
    Write-Host 'ビルドが完了しました'
}
