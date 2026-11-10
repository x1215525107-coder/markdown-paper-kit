# 论文 Git 速查表（方便优先版）

> 所有设备打开 OneDrive 里的同一个 `thesis` 文件夹。正常保存，自动同步；Git 提交用于主动留下历史版本。

## 平时写作

用 MarkText 正常写，保留自动保存。无需拖文件、生成版本包或在另一台导入。

## 想留一版时

```bash
cd "/你的实际 OneDrive 路径/thesis"
git add -A
git diff --cached --stat
git commit -m "修订: 补充第三章实验说明"
```

文字和当前使用的图片一起提交。说明写清楚即可，未完成的工作也可以提交。

配了别名的话，`cd "..."` 可用 `th` 代替（见 README §3.1）：

```bash
alias th='cd ~/OneDrive/thesis'    # 写进 ~/.zshrc（macOS）或 ~/.bashrc（Git Bash）
```

## 换机

**保存 → 等 OneDrive 上传完成 → 另一台下载完成 → 继续写。**

不强制提交，不做手动交接。同一时间只在一台设备上编辑项目。

## 看改动

```bash
git status
git log -5 --oneline
git diff -- manuscript/
git diff --cached -- manuscript/
git diff --word-diff=plain --word-diff-regex='[a-zA-Z0-9_]+|[^[:space:]]' -- manuscript/
```

`--cached` 看已暂存内容；中文逐字对比在 UTF-8 终端使用。

## 正式版

```bash
git tag -a thesis-20261110 -m "送导师审阅版"
git tag -l
git diff thesis-20261110 thesis-20261115 -- manuscript/
```

日期不用手打：

```bash
git tag -a "thesis-$(date +%Y%m%d)" -m "送导师审阅版"     # PowerShell 用 $(Get-Date -Format yyyyMMdd)
```

只查看旧稿：

```bash
git show thesis-20261110:manuscript/03-method.md
```

不必为了查看旧稿切换整个仓库。要恢复文件，先保存当前工作，再按 README 操作。

**别用 `git checkout thesis-20261110`**：那会进入游离状态，此时提交不属于任何分支，切回主线就找不到了。万一已经提交过：

```bash
git reflog                        # 找到哈希
git switch -c 救回 <commit-hash>   # 接回一个新分支
```

## 导出

首次：填写 `assets/metadata.yaml`，放入正文和 `refs.bib`，在 `assets/export-common.yaml` 调整章节顺序，生成并调整 Word 模板：

```bash
pandoc -o assets/reference.docx --print-default-data-file reference.docx
```

已有模板时不要覆盖。以后只需：

```bash
bash build.sh
```

Windows PowerShell 可用 `.\build.ps1`。生成 `export/thesis.tex`、`export/thesis.docx`。失败后不拿旧输出交付。

## 精排与备份

TeXPage 精排后按改动更新，不整篇覆盖已调整的正文。正式交付保留完整项目 ZIP 与实际 PDF / Word。

本地备份：**每周把整个 `thesis` 文件夹（含隐藏 `.git`）复制到移动硬盘或 U 盘。** 只拷 `.md` 得到的是当前稿，不含历史；备份目标别是同一个 OneDrive 目录。

```bash
cp -R ~/OneDrive/thesis /Volumes/备份盘/          # macOS
robocopy "%USERPROFILE%\OneDrive\thesis" "E:\备份\thesis" /MIR   # Windows
```

**区分两个“保存”：** OneDrive 自动同步已保存文件；只有 `git commit` 才创建新的 Git 版本。当前采用方便优先的共享仓库流程，同步边界见 README §1。
