# ========================================================================
# Script Name : cd-project-root.ps1
# Description : プロジェクトのルートディレクトリに移動する(ドットソース用)
# Usage       : . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

# プロジェクトルートを計算
$ProjectRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..\..')).FullName

# プロジェクトルートに移動
Set-Location -LiteralPath $ProjectRoot

# pyproject.toml の存在を確認
$PyprojectPath = Join-Path $ProjectRoot 'pyproject.toml'
if (-not (Test-Path -LiteralPath $PyprojectPath)) {
    throw "エラー: プロジェクトルートが見つかりません (pyproject.toml がありません): $ProjectRoot"
}
