# ========================================================================
# Script Name : rename-project.ps1
# Description : テンプレートのプロジェクト名を一括変更する
# Usage       : ./rename-project.ps1 <new-name> [copyright-holder]
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$NewName,

    [Parameter(Position = 1)]
    [string]$CopyrightHolder = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\common\wait-if-double-clicked.ps1')

Invoke-ScriptMain {
    . (Join-Path $PSScriptRoot '..\common\cd-project-root.ps1')

    $Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

    function Read-Utf8NoBom {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Path
        )

        return [System.IO.File]::ReadAllText($Path, $Utf8NoBom)
    }

    function Write-Utf8NoBom {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Path,

            [Parameter(Mandatory = $true)]
            [string]$Value
        )

        [System.IO.File]::WriteAllText($Path, $Value, $Utf8NoBom)
    }

    if ($NewName -notmatch '^[a-z][a-z0-9]*(-[a-z0-9]+)*$') {
        throw 'エラー: プロジェクト名は kebab-case で指定してください (例: my-project)'
    }

    $PyprojectPath = Join-Path $ProjectRoot 'pyproject.toml'
    $Pyproject = Read-Utf8NoBom -Path $PyprojectPath
    if ($Pyproject -notmatch '(?m)^name = "([^"]+)"') {
        throw 'エラー: pyproject.toml から name を読み取れません'
    }

    $CurrentName = $Matches[1]
    $NewIdent = $NewName -replace '-', '_'
    $OldIdent = $CurrentName -replace '-', '_'

    $NameUnchanged = $CurrentName -eq $NewName
    if ($NameUnchanged -and -not $CopyrightHolder) {
        Write-Host "プロジェクト名は既に `"$NewName`" です"
        return
    }

    if (-not $NameUnchanged) {
        Write-Host "プロジェクト名を `"$CurrentName`" から `"$NewName`" に変更しています..."
        Write-Host ''

        $OldPackageDir = Join-Path $ProjectRoot "src/$OldIdent"
        $NewPackageDir = Join-Path $ProjectRoot "src/$NewIdent"
        if (-not (Test-Path -LiteralPath $OldPackageDir)) {
            throw "エラー: パッケージディレクトリが見つかりません: $OldPackageDir"
        }
        if (Test-Path -LiteralPath $NewPackageDir) {
            throw "エラー: 移動先のパッケージディレクトリが既に存在します: $NewPackageDir"
        }

        Rename-Item -LiteralPath $OldPackageDir -NewName $NewIdent

        $Pyproject = $Pyproject -replace "name = `"$CurrentName`"", "name = `"$NewName`""
        $Pyproject = [regex]::Replace(
            $Pyproject,
            '(?m)^' + [regex]::Escape($CurrentName) + ' = "' + [regex]::Escape($OldIdent) + '\.cli:main"$',
            "$NewName = `"${NewIdent}.cli:main`""
        )
        Write-Utf8NoBom -Path $PyprojectPath -Value $Pyproject

        $InitPath = Join-Path $NewPackageDir '__init__.py'
        $InitContent = Read-Utf8NoBom -Path $InitPath
        $OldCrateRef = '`' + $CurrentName + '`'
        $NewCrateRef = '`' + $NewName + '`'
        $InitContent = $InitContent.Replace($OldCrateRef, $NewCrateRef)
        Write-Utf8NoBom -Path $InitPath -Value $InitContent

        Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'tests') -Filter '*.py' | ForEach-Object {
            $TestContent = Read-Utf8NoBom -Path $_.FullName
            $Updated = $TestContent.Replace("from ${OldIdent}", "from ${NewIdent}")
            if ($Updated -ne $TestContent) {
                Write-Utf8NoBom -Path $_.FullName -Value $Updated
            }
        }

        $LaunchPath = Join-Path $ProjectRoot '.vscode/launch.json'
        if (Test-Path -LiteralPath $LaunchPath) {
            $LaunchContent = Read-Utf8NoBom -Path $LaunchPath
            $LaunchContent = $LaunchContent.Replace($CurrentName, $NewName)
            $LaunchContent = $LaunchContent.Replace($OldIdent, $NewIdent)
            Write-Utf8NoBom -Path $LaunchPath -Value $LaunchContent
        }
    }

    if ($CopyrightHolder) {
        if ($NameUnchanged) {
            Write-Host "著作権者を `"$CopyrightHolder`" に更新しています..."
            Write-Host ''
        }

        $CopyrightLine = 'Copyright (c) 2026 ' + $CopyrightHolder
        $LicensePath = Join-Path $ProjectRoot 'LICENSE'
        $License = Read-Utf8NoBom -Path $LicensePath
        $License = [regex]::Replace($License, '(?m)^Copyright \(c\) .*', $CopyrightLine)
        Write-Utf8NoBom -Path $LicensePath -Value $License
    }

    Write-Host 'uv.lock を更新しています...'
    uv lock
    if ($LASTEXITCODE -ne 0) {
        throw "エラー: uv lock が終了コード $LASTEXITCODE で失敗しました"
    }
    Write-Host ''

    Write-Host '変更が完了しました。必要に応じて以下を手動で更新してください:'
    Write-Host '  - pyproject.toml の description, authors, repository'
    Write-Host '  - README.md のタイトル'
    if (-not $CopyrightHolder) {
        Write-Host '  - LICENSE の著作権表記(または copyright-holder を指定して再実行)'
    }
}
