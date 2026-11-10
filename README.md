# 学术论文 Markdown 写作套件

> 用 MarkText 写 Markdown 初稿，一键导出 LaTeX（送 TeXPage 排版）和 Word（交导师），
> Git 只管初稿、不管产物，双机靠 OneDrive 同步，**不需要任何远程仓库**。

一套给**中文科研工作者**准备的写作脚手架：Markdown 初稿 → Pandoc → LaTeX / Word。
重点是**轻量**和**能用**——不引入 LaTeX 本地编译、不引入 Git LFS、不要求你懂 Git 分支。

---

## 它解决什么

| 痛点 | 这套东西怎么处理 |
|---|---|
| Word 改十版就再也找不到"哪版是送审的" | Markdown + Git，每次提交可回看、可对比、可回退 |
| Markdown 里粘图片，转 Word 后图全丢 | 图片统一放 `manuscript/figures/`，路径相对化 |
| 参考文献格式每投一个刊就要手改 | 一行命令切期刊，CSL 自动套用 |
| 两台电脑（Win/Mac）稿子版本对不上 | OneDrive 同步 + 只在一台机器写的约定 |
| Pandoc 命令又长又记不住 | `bash build.sh` 一条命令，出三个文件 |
| 中文在 Pandoc 里各种坑 | 已经在配置里踩完并修好了（见下） |

**它不做什么**：不帮你写论文，不做文献管理（用 Zotero），不做 PDF 排版（用 TeXPage / Word）。

---

## 30 秒上手

```bash
# 1. 把 template 复制到你的云盘，改名成 _template
cp -R template ~/OneDrive/_template

# 2. 用模板生成第一篇论文
cd ~/OneDrive/_template
bash new-paper.sh ../paper-1

# 3. 写，然后导出
cd ../paper-1
bash build.sh          # → export/paper.tex  export/paper.docx  export/si.docx
```

Windows 用 `.\new-paper.ps1` 和 `.\build.ps1`。

**不想用终端**：直接把 `template/` 复制成 `paper-1`，在文件夹里执行一次
`git init -b main && git add -A && git commit -m "初稿: 初始化"`，
然后 GitHub Desktop → `File` → `Add local repository`。

### 可选：加两个跳转命令

文档里会出现 `cdp paper-1` 这种写法。它是个 shell 函数，加一次就能用：

```bash
# 把下面几行追加到 ~/.zshrc（macOS）或 ~/.bashrc（Git Bash）
cdp()  { cd "$HOME/OneDrive/$1" 2>/dev/null || { echo "没有这个仓库: $1"; cdpl; return 1; }; }
cdpl() { for d in "$HOME/OneDrive"/*/; do [ -d "${d}.git" ] && basename "$d"; done; }
```

改完重开终端。`cdp paper-1` 进论文一，`cdpl` 列出所有仓库。

不想加也没关系，把 `cdp paper-1` 换成 `cd ~/OneDrive/paper-1` 效果一样。

### 依赖

| 需要 | 装法 |
|---|---|
| Pandoc ≥ 3.x | macOS `brew install pandoc`；Windows `winget install JohnMacFarlane.Pandoc` |
| Git | macOS `xcode-select --install`；Windows 装 Git for Windows |
| 一个 Markdown 编辑器 | MarkText / Typora / Obsidian 均可 |
| （可选）可视化 Git | GitHub Desktop，双平台界面一致 |

**不需要**本地装 LaTeX——`.tex` 交给 TeXPage 编译。

---

## 目录结构

```
paper-1/                        ← 一篇论文 = 一个仓库
├── manuscript/                 ← 正文，全部入库
│   ├── 00-front.md             Highlights + Abstract + Keywords
│   ├── 01-intro.md             Introduction
│   ├── 02-methods.md           Materials and Methods
│   ├── 03-results.md           Results and Discussion
│   ├── 04-conclusion.md        Conclusions
│   ├── 05-backmatter.md        CRediT / 致谢 / 声明
│   ├── 90-si.md                Supporting Information（单独导出）
│   ├── refs.bib
│   └── figures/
├── assets/                     ← 模板与配置
│   ├── journals/               ← 每个期刊一份差异配置
│   ├── csl/                    ← 参考文献样式
│   ├── reference.docx          ← Word 字体样式模板
│   └── export-*.yaml           ← 章节顺序与导出设置
├── export/                     ← 产物，不进 Git
├── build.sh / build.ps1
└── tools/
    ├── add-journal.sh          加新期刊（自动同步到所有论文）
    └── sync-config.sh          把母版配置推送到所有论文
```

**数字前缀只是排序用，不是章节号。** 论文里的章节顺序由 `assets/export-common.yaml`
的 `input-files:` 列表决定，改顺序只改那里。

---

## 内置期刊

| 简称 | 期刊 | 参考文献样式 |
|---|---|---|
| `est` | Environmental Science & Technology (ACS) | ACS |
| `wr` | Water Research (Elsevier) | Elsevier Vancouver |
| `jhm` | Journal of Hazardous Materials | JHM 专属 |
| `cej` | Chemical Engineering Journal | Elsevier Vancouver |
| `nature` | Nature 系 | Nature |

```bash
bash build.sh jhm        # 换刊只换参数，正文不动
```

加一个新期刊：

```bash
cd _template
bash tools/add-journal.sh chemosphere ~/Downloads/chemosphere.csl
```

CSL 从 <https://www.zotero.org/styles> 下载。

**不同期刊的章节差异**（EST 常不要 Highlights、Nature 的 Methods 放最后）需要手动调整，
这部分脚本不代劳——它直接影响论文长什么样，改错了很难发现。

---

## 踩过的坑（已经在配置里修好）

如果你的 AI 或同事从零搭一套，这十条能省几个小时：

1. **MarkText 粘贴图片**：在 Finder 里复制"图片文件"再粘进 Markdown，得到的是绝对路径
   `/Users/xxx/Downloads/a.png`，换个电脑就空白。要复制**图片内容**（截图 / 右键"拷贝图像"），
   或者手动把图片放进 `figures/`。
2. **`pandoc --file-scope`** 让各文件的脚注互不冲突，代价是**跨文件的脚注和链接失效**。
3. **`lang: zh-CN` 在 Pandoc 里没有翻译**，会直接报错退出；必须写 `zh-Hans`。
4. 但 **`lang` 又会给 LaTeX 加上 `\documentclass[chinese-hans]` 和 babel**，与 `ctexbook` 冲突。
   实测 `lang` 对 Word 输出的中文标题**没有影响**，所以干脆不设。
5. **`reference.docx` 里字体默认是空的**，Word 会用主题默认字体。想改字体只能改这个文件，
   改 Markdown 或编辑器字体无效。
6. **多个 `--defaults` 会合并**（官方支持），这是把"结构 / 期刊 / 格式"三层配置拆开的依据。
7. **CSL 路径相对运行目录**，所以 `build.sh` 里必须有 `cd "$(dirname "$0")"`。
8. **一篇论文一个仓库**。混在一起时，回滚 A 会连带 B、tag 也说不清标的是谁。
9. **tag ≠ commit**。tag 不保存任何内容，只是给某次提交起名字。
10. **不要 `git checkout <tag>` 之后提交**——游离 head 上的提交不属于任何分支，
    `git log --all` 都看不到，只能靠 `git reflog` 找回。

---

## 双机与备份

- 仓库放在 OneDrive 里，`.git` 一起同步
- **同一时间只在一台机器上写**
- 换机前保存并等同步完成；换机后先 `git status` 确认干净
- 两个 OneDrive 同步根并存时，先确认哪个真的在同步（看客户端镜像里有没有那个文件夹）
- **没有远程仓库 = 没有异地备份**，每周把整个文件夹（含 `.git`）复制一份到移动硬盘

---

## 文档

| 文件 | 内容 |
|---|---|
| `template/怎么用.md` | 复制模板后的三步上手 |
| `template/改配置手册.md` | 加期刊、改字体、改章节、改错了怎么退 |
| `template/CHEATSHEET.md` | Git 命令速查 |
| `bootstrap-prompt.md` | 给 AI 的搭建提示词，可让别人快速复现 |

---

## 许可

- 本仓库的脚本与文档：MIT
- `assets/csl/*.csl`：来自 [citation-style-language/styles](https://github.com/citation-style-language/styles)，
  **CC BY-SA 3.0**，详见 `NOTICE.md`

欢迎提 Issue / PR 补充新的期刊配置。
