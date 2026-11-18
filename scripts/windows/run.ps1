# ========================================================================
# Script Name : run.ps1
# Description : Windows用のアプリ実行スクリプト
# Usage       : ./run.ps1 [args...]
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

# Invoke-ScriptMain の scriptblock 内では $args が空になるため、先に確保する
$AppArgs = @($args)

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    [Console]::Error.WriteLine('アプリケーションを実行しています...')
    [Console]::Error.WriteLine()

    uv run python-template @AppArgs
}
