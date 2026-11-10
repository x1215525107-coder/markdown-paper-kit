# 用法：.\build.ps1 est    （可选: est wr jhm cej nature，默认 est）
param([string]$Journal = "est")

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

$profile = "assets/journals/$Journal.yaml"
if (-not (Get-Command pandoc -CommandType Application -ErrorAction SilentlyContinue)) {
    throw "Pandoc is not installed or is not on PATH."
}
if (-not (Test-Path -LiteralPath "assets/reference.docx" -PathType Leaf)) {
    throw "Create and customize assets/reference.docx first (README section 4)."
}
if (-not (Test-Path -LiteralPath $profile -PathType Leaf)) {
    $names = (Get-ChildItem "assets/journals/*.yaml").BaseName -join " "
    throw "未知期刊: $Journal。可选: $names"
}

New-Item -ItemType Directory -Force -Path "export" | Out-Null
Write-Host "→ 期刊配置: $Journal"
& pandoc --defaults=assets/export-common.yaml --defaults=$profile --defaults=assets/export-latex.yaml
if ($LASTEXITCODE -ne 0) { throw "LaTeX export failed (exit code $LASTEXITCODE)." }
& pandoc --defaults=assets/export-common.yaml --defaults=$profile --defaults=assets/export-word.yaml
if ($LASTEXITCODE -ne 0) { throw "Word export failed (exit code $LASTEXITCODE)." }
& pandoc --defaults=assets/export-si.yaml --defaults=$profile
if ($LASTEXITCODE -ne 0) { throw "SI export failed (exit code $LASTEXITCODE)." }
Write-Host "OK: export/paper.tex  export/paper.docx  export/si.docx"
