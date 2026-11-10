#!/usr/bin/env bash
# 新增一个期刊：下载/复制 CSL，生成配置，同步到所有论文仓库
#
# 用法：
#   bash tools/add-journal.sh <简称> <CSL 文件路径或下载地址>
#   bash tools/add-journal.sh es  https://raw.githubusercontent.com/citation-style-language/styles/master/american-chemical-society.csl
#   bash tools/add-journal.sh wr  ~/Downloads/water-research.csl
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:-}"; CSL="${2:-}"
if [ -z "$NAME" ] || [ -z "$CSL" ]; then
  echo "用法: bash tools/add-journal.sh <简称> <CSL文件或URL>" >&2; exit 1
fi
if [ -f "$SRC/assets/journals/$NAME.yaml" ]; then
  echo "已存在 assets/journals/$NAME.yaml，未做改动" >&2; exit 1
fi

mkdir -p "$SRC/assets/csl"
if [[ "$CSL" == http* ]]; then
  OUT="$SRC/assets/csl/$(basename "${CSL%%\?*}")"
  echo "下载：$CSL"
  export https_proxy="${https_proxy:-http://127.0.0.1:7897}"
  export http_proxy="${http_proxy:-http://127.0.0.1:7897}"
  if ! curl -sL --http1.1 --retry 3 --retry-delay 2 -o "$OUT" "$CSL"; then
    echo "下载失败：网络或代理问题（curl 出错）" >&2
    echo "可以手动下载后改用本地文件：bash tools/add-journal.sh $NAME ~/Downloads/xxx.csl" >&2
    rm -f "$OUT"; exit 1
  fi
  if [ ! -s "$OUT" ]; then
    echo "下载到的文件是空的，URL 可能不对：$CSL" >&2; rm -f "$OUT"; exit 1
  fi
else
  OUT="$SRC/assets/csl/$(basename "$CSL")"
  if [ "$(cd "$(dirname "$CSL")" && pwd -P)/$(basename "$CSL")" != "$(cd "$(dirname "$OUT")" && pwd -P)/$(basename "$OUT")" ]; then
    cp "$CSL" "$OUT"
  else
    echo "CSL 已在 assets/csl/ 里，跳过复制"
  fi
fi

cat > "$SRC/assets/journals/$NAME.yaml" <<EOF
# ${NAME} —— 参考文献样式
csl: assets/csl/$(basename "$OUT")
EOF

echo "✅ 已添加期刊 $NAME → assets/journals/$NAME.yaml"
echo "   CSL: assets/csl/$(basename "$OUT")"
echo
bash "$SRC/tools/sync-config.sh"
