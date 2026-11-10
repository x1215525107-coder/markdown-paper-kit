# 第三方素材说明

本仓库的脚本和文档采用 MIT 许可（见 `LICENSE`），但下面这些文件来自第三方，
适用各自的许可，**不受 MIT 覆盖**。

## CSL 参考文献样式

位置：`template/assets/csl/*.csl`

- `american-chemical-society.csl`
- `elsevier-vancouver.csl`
- `journal-of-hazardous-materials.csl`
- `nature.csl`

来源：<https://github.com/citation-style-language/styles>

许可：**Creative Commons Attribution-ShareAlike 3.0 License (CC BY-SA 3.0)**
<https://creativecommons.org/licenses/by-sa/3.0/>

每个 `.csl` 文件内部保留了原始的 `<rights>` 声明和作者信息，请勿删除。

**注意 ShareAlike 条款**：如果你修改了这些 `.csl` 文件并分发，修改后的版本也必须以
CC BY-SA 3.0 发布。仅仅使用它们生成参考文献不受此限制。

如果需要其他期刊的样式，请从 <https://www.zotero.org/styles> 自行下载，
不要把整份样式库复制进本仓库。

## Pandoc

本仓库不包含 Pandoc 本身，只在脚本中调用。Pandoc 采用 GPL-2.0-or-later。

`template/assets/reference.docx` 由 Pandoc 的
`pandoc -o reference.docx --print-default-data-file reference.docx` 生成后修改，
同样遵循 Pandoc 的数据文件许可。
