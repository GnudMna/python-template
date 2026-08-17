# ========================================================================
# Script Name : rename-project.ps1
# Description : テンプレートのプロジェクト名を一括変更する
# Usage       : ./rename-project.ps1 <new-name> [author] [email]
# Requires    : PowerShell 7.0+
# ========================================================================

#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$NewName,

    [Parameter(Position = 1)]
    [Alias('CopyrightHolder')]
    [string]$Author = '',

    [Parameter(Position = 2)]
    [string]$Email = ''
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

    function Update-NameInFile {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Path,

            [Parameter(Mandatory = $true)]
            [string]$CurrentName,

            [Parameter(Mandatory = $true)]
            [string]$NewName,

            [Parameter(Mandatory = $true)]
            [string]$OldIdent,

            [Parameter(Mandatory = $true)]
            [string]$NewIdent
        )

        if (-not (Test-Path -LiteralPath $Path)) {
            return
        }

        $Content = Read-Utf8NoBom -Path $Path
        $Updated = $Content.Replace($CurrentName, $NewName).Replace($OldIdent, $NewIdent)
        if ($Updated -ne $Content) {
            Write-Utf8NoBom -Path $Path -Value $Updated
        }
    }

    if ($NewName -notmatch '^[a-z][a-z0-9]*(-[a-z0-9]+)*$') {
        throw 'エラー: プロジェクト名は kebab-case で指定してください (例: my-project)'
    }

    if ($Author.Contains('"') -or $Email.Contains('"')) {
        throw 'エラー: author / email にダブルクォートは使えません'
    }

    if ($Email -and $Email -notmatch '@') {
        throw 'エラー: email の形式が正しくありません'
    }

    $PyprojectPath = Join-Path $ProjectRoot 'pyproject.toml'
    $Pyproject = Read-Utf8NoBom -Path $PyprojectPath
    if ($Pyproject -notmatch '(?m)^name = "([^"]+)"') {
        throw 'エラー: pyproject.toml から name を読み取れません'
    }

    $CurrentName = $Matches[1]
    $NewIdent = $NewName -replace '-', '_'
    $OldIdent = $CurrentName -replace '-', '_'
    $PyprojectChanged = $false

    $NameUnchanged = $CurrentName -eq $NewName
    if ($NameUnchanged -and -not $Author -and -not $Email) {
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
        $PyprojectChanged = $true

        Update-NameInFile -Path (Join-Path $NewPackageDir '__init__.py') `
            -CurrentName $CurrentName -NewName $NewName -OldIdent $OldIdent -NewIdent $NewIdent

        Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'tests') -Filter '*.py' -ErrorAction SilentlyContinue |
            ForEach-Object {
                $TestContent = Read-Utf8NoBom -Path $_.FullName
                $Updated = $TestContent.Replace("from ${OldIdent}", "from ${NewIdent}")
                if ($Updated -ne $TestContent) {
                    Write-Utf8NoBom -Path $_.FullName -Value $Updated
                }
            }

        foreach ($RelativePath in @(
                'README.md',
                '.vscode/launch.json',
                'scripts/linux/run.sh',
                'scripts/macos/run.sh',
                'scripts/windows/run.ps1'
            )) {
            Update-NameInFile -Path (Join-Path $ProjectRoot $RelativePath) `
                -CurrentName $CurrentName -NewName $NewName -OldIdent $OldIdent -NewIdent $NewIdent
        }
    }

    if ($Author) {
        if ($NameUnchanged) {
            Write-Host "著作権者と authors を `"$Author`" に更新しています..."
            Write-Host ''
        }

        $Year = (Get-Date).Year
        $CopyrightLine = "Copyright (c) $Year $Author"
        $LicensePath = Join-Path $ProjectRoot 'LICENSE'
        $License = Read-Utf8NoBom -Path $LicensePath
        $License = [regex]::Replace($License, '(?m)^Copyright \(c\) .*', $CopyrightLine)
        Write-Utf8NoBom -Path $LicensePath -Value $License

        $Pyproject = [regex]::Replace(
            $Pyproject,
            '(\{ name = ")[^"]+(", email =)',
            { param($Match) $Match.Groups[1].Value + $Author + $Match.Groups[2].Value }
        )
        $PyprojectChanged = $true
    }

    if ($Email) {
        $Pyproject = [regex]::Replace(
            $Pyproject,
            '(\{ name = "[^"]+", email = ")[^"]+(")',
            { param($Match) $Match.Groups[1].Value + $Email + $Match.Groups[2].Value }
        )
        $PyprojectChanged = $true
    }

    if ($PyprojectChanged) {
        Write-Utf8NoBom -Path $PyprojectPath -Value $Pyproject
    }

    if (-not $NameUnchanged) {
        Write-Host 'uv.lock を更新しています...'
        uv lock
        if ($LASTEXITCODE -ne 0) {
            throw "エラー: uv lock が終了コード $LASTEXITCODE で失敗しました"
        }
        Write-Host ''
    }

    Write-Host '変更が完了しました。必要に応じて以下を手動で更新してください:'
    Write-Host '  - pyproject.toml の description, repository'
    Write-Host '  - README.md のプロジェクト説明文'
    if (-not $Author) {
        Write-Host '  - LICENSE の著作権表記と pyproject.toml の authors.name (または author を指定して再実行)'
    }
    if (-not $Email) {
        Write-Host '  - pyproject.toml の authors.email (または email を指定して再実行)'
    }
}
