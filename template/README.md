# paper-1 —— 期刊论文仓库

> 面向 **Water Research / Journal of Hazardous Materials / Chemical Engineering Journal / EST** 的英文 IMRaD 初稿。
> MarkText 写 Markdown → Pandoc 导出 LaTeX（送 TeXPage）/ Word（送导师）→ 投稿。
> 版本管理只在初稿阶段；排版阶段的修改不进本仓库。

---

## 1. 先看这里：一篇文章怎么写

```
写稿（MarkText）   →   导出（bash build.sh）   →   排版（TeXPage / Word）   →   投稿
     ↑                                              ↑
   git commit                                   只在 TeXPage 改版式
```

**你每天只需要做一件事**：写完一段，在 GitHub Desktop 里点一次 Commit。
不用每次保存都提交，提交是"留一个可回看的版本"，不是"保存"。

---

## 2. 目录结构与每个文件对应哪一节

```
paper-1/
├── manuscript/                      ← 正文源文件，全部入库
│   ├── 00-front.md                  Highlights + Abstract + Keywords
│   ├── 01-intro.md                  Introduction
│   ├── 02-methods.md                Materials and Methods
│   ├── 03-results.md                Results and Discussion
│   ├── 04-conclusion.md             Conclusions
│   ├── 05-backmatter.md             Author Information / Acknowledgments / CRediT / Declaration
│   ├── 90-si.md                     Supporting Information（单独导出）
│   ├── refs.bib                     参考文献（从 Zotero 导出覆盖）
│   └── figures/                     插图（PNG 300dpi；矢量图放 figures/vector/）
│
├── assets/                          ← 模板与配置，入库
│   ├── metadata.yaml                标题、作者
│   ├── export-common.yaml           ★ 章节顺序与公共设置（只在这里改）
│   ├── export-latex.yaml            导出 .tex（article 类，section 级）
│   ├── export-word.yaml             导出 .docx
│   ├── export-si.yaml               导出 SI（独立文档）
│   ├── texpage-template.tex         导言区宏包
│   ├── reference.docx               Word 样式模板
│   ├── journals/                    ★ 每个期刊一份差异配置（est/wr/jhm/cej/nature）
│   └── csl/                         参考文献样式文件
│
├── export/                          ← 产物，不进 Git（OneDrive 仍会同步）
│   ├── paper.tex
│   ├── paper.docx
│   └── si.docx
│
├── build.sh / build.ps1             macOS / Windows 导出入口
├── CHEATSHEET.md                    Git 速查表
└── RELEASES.md                      投稿记录（哪个 tag 投了哪家期刊）
```

**数字前缀（00/01/90/99）只是排序用，不是章节号。** 正文里的 "1 Introduction" 来自你写的 `#` 标题，编号由 `number-sections` 自动生成。

---

## 3. 换期刊：只改一个参数

正文文件永远不动，换期刊只需要一条命令：

```bash
bash build.sh est        # 默认
bash build.sh wr
bash build.sh jhm
bash build.sh cej
bash build.sh nature
```

Windows：

```powershell
.\build.ps1 est
```

### 3.1 这一层自动化的原理

```
assets/journals/est.yaml      只写这一个期刊和别家不同的地方（目前是 CSL）
assets/journals/wr.yaml
assets/journals/jhm.yaml
assets/journals/cej.yaml
assets/journals/nature.yaml
assets/csl/*.csl              参考文献样式文件
```

`build.sh` 把 `export-common.yaml`（结构）+ `journals/<刊>.yaml`（期刊差异）+ `export-latex.yaml`（输出格式）三份配置叠加起来用。

**新增期刊**：复制 `assets/journals/wr.yaml`，改名，换 `csl:` 那一行即可（CSL 从 Zotero 样式库下载，丢进 `assets/csl/`）。

实测四个刊的参考文献格式确实不同：

| 期刊 | 参考文献呈现 | 正文引用 |
|---|---|---|
| EST (ACS) | `(1) Smith, J. A.; Doe, J. Chain Elongation…` | 上标 |
| Nature | `1. Smith, J. A. & Doe, J. Chain elongation…` | 上标 |
| WR / CEJ (Elsevier) | `[1] Smith JA, Doe J. Chain elongation…` | 方括号 |
| JHM | `[1] Smith JA, Doe J, 2020. Chain elongation…` | 方括号 |

### 3.2 自动化管不到的部分（投稿前手动处理）

换期刊还有三类差异，**这些得靠你在投稿前调**，YAML 解决不了：

| 差异 | 说明 | 处理 |
|---|---|---|
| **章节取舍** | EST 通常不要 Highlights；Nature 不拆 Results/Discussion，literally 叫 "Main text"，Methods 放最后 | 删/调 `manuscript/` 里对应小节，或临时改 `export-common.yaml` 的 `input-files` 顺序 |
| **字数/条数上限** | Nature Letter 正文约 3000 词、参考文献约 50 条；Elsevier 摘要 ≤250 词 | 投稿前数一遍 |
| **图表物理规格** | 单栏/双栏宽度、字号、分辨率 | 排版阶段按目标刊要求出图 |

**图表宽度参考**（先按最宽的做，缩小不吃亏）：

| 出版方 | 单栏 | 双栏 | 最小分辨率 |
|---|---|---|---|
| Elsevier | 90 mm | 190 mm | 300 dpi（线条图 1000 dpi） |
| ACS | 82.6 mm | 177.8 mm | 300 dpi |
| Nature | 89 mm | 183 mm | 300 dpi，图上文字 5–7 pt |

正文里统一写 `{width=14cm}` 这类相对宽度，具体尺寸到排版阶段再调。

## 4. 首次准备（只做一次）

### 4.1 生成 Word 样式模板

```bash
pandoc -o assets/reference.docx --print-default-data-file reference.docx
```

> **当前模板已经配好字体**：正文 Times New Roman + 宋体，标题黑体，图注 9pt。
> 想改就得编辑这个文件——**改 Markdown 或 MarkText 的显示字体没有任何作用**（Markdown 里不存在字体概念）。

用 Word 打开 `assets/reference.docx`，改这些样式后保存（**已有模板时不要覆盖**）：

- `Normal`：Times New Roman 12pt，双倍行距，段后 0
- `Heading 1/2/3`：加粗，字号递减
- `Body Text`：正文段落
- `Image Caption` / `Table Caption`：图注表注

### 4.2 参考文献样式

`export-common.yaml` 里 `csl:` 默认是注释掉的，此时用的是 Pandoc 默认样式，**不是期刊要求的格式**。

从 Zotero 样式库下载对应 CSL 放进 `assets/`，然后取消注释：

| 目标期刊 | CSL |
|---|---|
| EST | `american-chemical-society.csl` |
| Water Research / JHM / CEJ | 对应期刊 CSL（Elsevier 系，多为数字编号） |

### 4.3 填标题和作者

编辑 `assets/metadata.yaml`。

---

## 5. 同时写多篇论文

**规则：一篇论文 = 一个仓库。** 不要在一篇里塞多篇，理由见下方"为什么"。

### 5.1 新建一篇

```bash
cdp paper-1                 # 先进入任意一个已有仓库当模板
bash new-paper.sh paper-3   # 会在旁边生成 ../paper-3
```

脚本会自动：复制全部配置（期刊配置、CSL、build 脚本、.gitignore）、生成空正文骨架、建好 Git 仓库并提交第一次。

Windows：

```powershell
.\new-paper.ps1 paper-3
```

### 5.2 日常在多个仓库间跳转

```bash
cdpl            # 列出你所有的论文仓库
cdp paper-1     # 进入 paper-1
cdp paper-3     # 进入 paper-3
cdp thesis      # 进入学位论文
```

（也可以一直用 `pp` 进 paper-1，`th` 进 thesis。）

### 5.3 为什么一篇一仓库

| 原因 | 说明 |
|---|---|
| **tag 语义** | `paper1-20261110` 只该标记第一篇那一版。混在一起，tag 就说不清标的是什么 |
| **回滚安全** | 切 tag / reset 作用于整个仓库。混在一起时，回滚第一篇会连带把第二篇退回去 |
| **同步单元** | 两篇独立，一台写 A、另一台写 B 完全安全；共用一个 `.git` 就做不到了 |
| **投不同的刊** | 每篇有自己的 `assets/journals/` 选择，互不干扰 |
| **归档** | `git archive` 打一个包 = 一篇，能直接发人 |

代价：每篇的 `refs.bib`、`reference.docx` 各一份。可以接受。

### 5.4 如果两篇内容高度重叠

比如"学位论文抽出一篇期刊文章"。建议：**在抽取那一刻作为新仓库的起点，之后各自演进，不再互相同步。** 否则你会一直两边手工复制，两边逐渐不一致。

## 6. 日常导出

```bash
bash build.sh est      # macOS / Git Bash，参数换成目标期刊
.\build.ps1 est        # Windows PowerShell
```

一次产出三个文件：

| 文件 | 用途 |
|---|---|
| `export/paper.tex` | 上传 TeXPage 排版 |
| `export/paper.docx` | 发给导师 / 改批注 |
| `export/si.docx` | Supporting Information，投稿时单独上传 |

**脚本全部成功才打印 OK**；失败会停在那一步，不要拿上次的旧文件当本次结果。

常见报错：

| 报错 | 含义 | 去哪改 |
|---|---|---|
| `citation ... not found` | 文献 key 对不上 | `manuscript/refs.bib` |
| `Could not fetch resource` | 图片路径错 | `.md` 里的 `figures/...` |
| `reference.docx` 相关 | 模板没生成 | 重跑 4.1 |

---

## 7. 图片

正文里只引位图，并显式写宽度：

```markdown
![Figure 1. 系统示意图](figures/fig01.png){width=14cm}
```

- 期刊插图一般要求 **≥300 dpi**，单栏 8.5 cm、双栏 17.5 cm 宽
- 矢量图放 `manuscript/figures/vector/*.pdf`，排版阶段替换
- **MarkText 不认 `{width=}` 属性**，预览里会显示成字面文字，不影响导出
- 粘贴图片时如果正文出现 `/Users/` 开头的绝对路径，说明只是写了个文件位置，要把图片挪进 `figures/` 再改成相对路径

---

## 8. Git 与 OneDrive

- 仓库在 OneDrive 内，`.git` 一起同步
- **同一时间只在一台电脑上编辑**
- 换机前：保存，等 OneDrive 显示"已是最新"
- 换机后：等下载完成，`git status` 干净再动笔
- 每周把整个 `paper-1` 文件夹（含隐藏 `.git`）复制一份到移动硬盘

版本标记（投稿前打）：

```bash
git tag -a "paper1-$(date +%Y%m%d)" -m "投 Water Research 初稿"
```
