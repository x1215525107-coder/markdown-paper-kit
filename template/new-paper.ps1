# 用法：.\new-paper.ps1 paper-2
param([Parameter(Mandatory=$true)][string]$Name)
$ErrorActionPreference = "Stop"
$src = $PSScriptRoot
$dst = Join-Path (Split-Path $src -Parent) $Name
if (Test-Path $dst) { throw "已存在，未做任何改动: $dst" }

New-Item -ItemType Directory -Force -Path "$dst/manuscript/figures" | Out-Null
New-Item -ItemType Directory -Force -Path "$dst/export" | Out-Null
Set-Content -Path "$dst/.kit" -Value "paper" -Encoding ASCII
Copy-Item "$src/assets" -Destination $dst -Recurse
Copy-Item "$src/build.sh" -Destination $dst
Copy-Item "$src/build.ps1" -Destination $dst
Copy-Item "$src/new-paper.sh" -Destination $dst
Copy-Item "$src/new-paper.ps1" -Destination $dst
Copy-Item "$src/.gitignore" -Destination $dst
Copy-Item "$src/.gitattributes" -Destination $dst
Copy-Item "$src/CHEATSHEET.md" -Destination $dst
Copy-Item "$src/README.md" -Destination $dst
Copy-Item "$src/RELEASES.md" -Destination $dst

$files = @{
  "00-front.md"      = "# Highlights {-}`n`n- `n- `n- `n`n# Abstract {-}`n`n`n# Keywords {-}`n"
  "01-intro.md"      = "# Introduction`n`n"
  "02-methods.md"    = "# Materials and Methods`n`n## Chemicals and Materials`n`n## Experimental Setup`n`n## Analytical Methods`n`n## Data Analysis`n"
  "03-results.md"    = "# Results and Discussion`n`n"
  "04-conclusion.md" = "# Conclusions`n`n"
  "05-backmatter.md" = "# Author Information {-}`n`n**Corresponding Author**`n`n**Notes**`n`nThe authors declare no competing financial interest.`n`n# Acknowledgments {-}`n`n# CRediT Authorship Contribution Statement {-}`n`n# Declaration of Competing Interest {-}`n"
  "90-si.md"         = "# Supporting Information`n`n## Supplementary Figures`n`n## Supplementary Tables`n"
  "refs.bib"         = "% 参考文献（BibTeX）`n% 从 Zotero 导出：选中条目 → 右键 → Export Items → BibTeX → 覆盖本文件`n"
}
foreach ($k in $files.Keys) {
    Set-Content -Path "$dst/manuscript/$k" -Value $files[$k] -Encoding UTF8 -NoNewline
}

@"
title: "Paper title (fill in)"
author:
  - "Author One"
date: ""
lang: en-US
"@ | Set-Content -Path "$dst/assets/metadata.yaml" -Encoding UTF8

$gitName  = (git config --get user.name)
$gitEmail = (git config --get user.email)
if (-not $gitName -or -not $gitEmail) {
    throw "还没有设置 Git 身份。先执行：`n  git config --global user.name  `"你的名字`"`n  git config --global user.email `"you@example.com`""
}

Push-Location $dst
git init -b main | Out-Null
git config --local user.name $gitName
git config --local user.email $gitEmail
git config --local core.autocrlf false
git config --local core.quotepath false
git config --local core.filemode false
git add -A
git commit -q -m "初稿: 初始化论文项目"
Pop-Location

Write-Host "OK: $dst"
