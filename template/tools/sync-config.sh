#!/usr/bin/env bash
# 把母版 _template 里的共享配置同步到所有论文仓库（不动学位论文 thesis）
#
# 同步内容：期刊配置 journals/、参考文献样式 csl/、Word 字体模板 reference.docx、
#          build 脚本、.gitignore、.gitattributes
# 不同步：manuscript/（正文）、assets/export-*.yaml（每篇可能自己调过）
#
# 用法：bash tools/sync-config.sh [--dry-run]
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(dirname "$SRC")"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

FILES=(build.sh build.ps1 new-paper.sh new-paper.ps1 .gitignore .gitattributes 改配置手册.md)
DIRS=(assets/journals assets/csl)
EXTRA=(assets/reference.docx)

targets=()
while IFS= read -r d; do
  real="$(cd "$d" && pwd -P)"
  [ "$real" = "$(cd "$SRC" && pwd -P)" ] && continue
  [ -f "$d/.kit" ] || continue
  [ "$(tr -d '[:space:]' < "$d/.kit")" = "paper" ] || continue
  targets+=("$d")
done < <(find "$ROOT" -maxdepth 1 -mindepth 1 -type d -exec test -d '{}/.git' \; -print | sort)

if [ ${#targets[@]} -eq 0 ]; then
  echo "没有找到论文仓库（需要 .git 目录和 .kit 文件写着 paper）"; exit 0
fi

for d in "${targets[@]}"; do
  name="$(basename "$d")"
  echo "→ $name"
  if [ "$DRY" -eq 1 ]; then echo "   (dry-run，不实际写入)"; continue; fi
  for f in "${FILES[@]}"; do
    [ -f "$SRC/$f" ] && cp "$SRC/$f" "$d/$f"
  done
  for dir in "${DIRS[@]}"; do
    [ -d "$SRC/$dir" ] && { mkdir -p "$d/$dir"; cp -R "$SRC/$dir/." "$d/$dir/"; }
  done
  for f in "${EXTRA[@]}"; do
    [ -f "$SRC/$f" ] && cp "$SRC/$f" "$d/$f"
  done
  chmod +x "$d/build.sh" 2>/dev/null || true
  echo "   期刊: $(ls "$d/assets/journals"/*.yaml 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/.yaml//' | tr '\n' ' ')"
done

echo
echo "完成。各仓库的改动需要自己提交（或用 git restore 丢弃）。"
