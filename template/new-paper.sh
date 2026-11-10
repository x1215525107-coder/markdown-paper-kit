#!/usr/bin/env bash
# 用当前这套配置新建一篇论文仓库
# 用法：bash new-paper.sh paper-2
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
NAME="${1:-}"

if [ -z "$NAME" ]; then
  echo "用法: bash new-paper.sh <仓库名>" >&2
  echo "例如: bash new-paper.sh paper-2" >&2
  exit 1
fi

DST="$(dirname "$SRC")/$NAME"
if [ -e "$DST" ]; then
  echo "已存在，未做任何改动: $DST" >&2
  exit 1
fi

mkdir -p "$DST/manuscript/figures" "$DST/export"

# 标记这个仓库属于"论文"类型，sync-config.sh 靠它决定要不要同步
printf 'paper\n' > "$DST/.kit"

# 1. 配置与模板（期刊配置、CSL、脚本、忽略规则）
cp -R "$SRC/assets" "$DST/assets"
cp "$SRC"/build.sh "$SRC"/build.ps1 "$SRC"/new-paper.sh "$SRC"/new-paper.ps1 \
   "$SRC"/.gitignore "$SRC"/.gitattributes \
   "$SRC"/CHEATSHEET.md "$SRC"/README.md "$SRC"/RELEASES.md "$DST"/
chmod +x "$DST/build.sh" "$DST/new-paper.sh"

# 2. 空的正文骨架
cat > "$DST/manuscript/00-front.md" <<'EOF'
# Highlights {-}

- 
- 
- 

# Abstract {-}


# Keywords {-}

EOF

printf '# Introduction\n\n' > "$DST/manuscript/01-intro.md"

cat > "$DST/manuscript/02-methods.md" <<'EOF'
# Materials and Methods

## Chemicals and Materials

## Experimental Setup

## Analytical Methods

## Data Analysis
EOF

printf '# Results and Discussion\n\n' > "$DST/manuscript/03-results.md"
printf '# Conclusions\n\n' > "$DST/manuscript/04-conclusion.md"

cat > "$DST/manuscript/05-backmatter.md" <<'EOF'
# Author Information {-}

**Corresponding Author**

**Notes**

The authors declare no competing financial interest.

# Acknowledgments {-}


# CRediT Authorship Contribution Statement {-}


# Declaration of Competing Interest {-}
EOF

printf '# Supporting Information\n\n## Supplementary Figures\n\n## Supplementary Tables\n' > "$DST/manuscript/90-si.md"

printf '%% 参考文献（BibTeX）\n%% 从 Zotero 导出：选中条目 → 右键 → Export Items → BibTeX → 覆盖本文件\n' > "$DST/manuscript/refs.bib"

# 3. 元数据清空成占位
cat > "$DST/assets/metadata.yaml" <<'EOF'
title: "Paper title (fill in)"
author:
  - "Author One"
date: ""
lang: en-US
EOF

# 4. 建仓
cd "$DST"
git init -q -b main
GIT_NAME="$(git config --get user.name  2>/dev/null || true)"
GIT_EMAIL="$(git config --get user.email 2>/dev/null || true)"
if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
  echo "还没有设置 Git 身份，先执行这两条（只做一次）：" >&2
  echo '  git config --global user.name  "你的名字"' >&2
  echo '  git config --global user.email "you@example.com"' >&2
  echo "然后重新运行本脚本。" >&2
  exit 1
fi
git config --local user.name  "$GIT_NAME"
git config --local user.email "$GIT_EMAIL"
git config --local core.autocrlf false
git config --local core.quotepath false
git config --local core.filemode false
git add -A
git commit -q -m "初稿: 初始化论文项目"

echo "✅ 已创建：$DST"
echo "   期刊配置: $(ls assets/journals/*.yaml | xargs -n1 basename | sed 's/.yaml//' | tr '\n' ' ')"
echo "   下一步: cd \"$DST\" && bash build.sh est"
