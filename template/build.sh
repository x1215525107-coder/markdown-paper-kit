#!/usr/bin/env bash
# 用法：bash build.sh [est|wr|jhm|cej|nature]
# 不写参数默认 est
set -euo pipefail
cd "$(dirname "$0")"

JOURNAL="${1:-est}"
PROFILE="assets/journals/${JOURNAL}.yaml"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Pandoc is not installed or is not on PATH." >&2
  exit 1
fi
if [ ! -f assets/reference.docx ]; then
  echo "Create and customize assets/reference.docx first (README section 4)." >&2
  exit 1
fi
if [ ! -f "$PROFILE" ]; then
  echo "未知期刊: ${JOURNAL}" >&2
  echo "可选: $(ls assets/journals/*.yaml | xargs -n1 basename | sed 's/.yaml//' | tr '\n' ' ')" >&2
  exit 1
fi

mkdir -p export

# Word 打开着 docx 时，文件能重新生成，但 Word 显示的是它加载时的旧内容
if command -v lsof >/dev/null 2>&1; then
  for f in export/*.docx; do
    [ -f "$f" ] || continue
    if lsof -t "$f" >/dev/null 2>&1; then
      echo "⚠️  $f 正被别的程序打开（多半是 Word）。构建会成功，但要【关闭再重新打开】才能看到新内容。" >&2
      break
    fi
  done
fi
echo "→ 期刊配置: ${JOURNAL}"
pandoc --defaults=assets/export-common.yaml --defaults="$PROFILE" --defaults=assets/export-latex.yaml
pandoc --defaults=assets/export-common.yaml --defaults="$PROFILE" --defaults=assets/export-word.yaml
pandoc --defaults=assets/export-si.yaml --defaults="$PROFILE"
echo "OK: export/paper.tex  export/paper.docx  export/si.docx"
