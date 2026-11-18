# ========================================================================
# Script Name : rename-project.ps1
# Description : テンプレートのプロジェクト名を一括変更する
#               処理本体は scripts/rename_project.py
# Usage       : ./rename-project.ps1 <new-name> [author] [email]
# Requires    : PowerShell 7.4+
# ========================================================================

#requires -Version 7.4

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

# Invoke-ScriptMain の scriptblock 内では $args が空になるため、先に確保する
$RenameArgs = @($args)

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    uv run --no-project python scripts/rename_project.py @RenameArgs
}
