# wsl-community

[English](README.md) | [中文](README.zh-CN.md)

**[WSL Dashboard](https://github.com/owu/wsl-dashboard) 的社区脚本和数据资源仓库。**

本仓库托管 WSL Dashboard 所需的脚本工具和 JSON 数据端点，合并到 `main` 分支后自动发布到 CDN，供软件在线调用。

> **注意**：这是**数据与脚本**仓库。主应用程序请访问 [wsl-dashboard](https://github.com/owu/wsl-dashboard)。

---

## 架构概览

```
wsl-community 仓库
       │
       │  提交 PR 来合并修改
       ▼
  自动发布到 CDN
       │
       │  WSL Dashboard 软件调用
       ▼
    用户设备
```

本仓库 `main` 分支的 `www/` 目录内容会自动发布到 CDN，通过 `https://api3.wslui.com` 域名访问。目录结构直接映射为 URL 路径。

---

## 目录结构

```
wsl-community/
├── README.md                    # 英文说明（不发布）
├── README.zh-CN.md              # 中文说明（不发布）
├── LICENSE                      # GPLv3 许可证（不发布）
│
├── documents/                   # 开发文档（不发布到 CDN）
│   ├── zh-CN/                   # 中文文档
│   │   ├── data-source.md       # 数据来源与过滤规则
│   │   ├── debug-config.md      # 调试配置说明
│   │   └── mirrors.yml          # 镜像站参考列表
│   └── en/                      # 英文文档
│       ├── data-source.md
│       ├── debug-config.md
│       └── mirrors.yml
│
├── scripts/                     # 仓库级工具脚本（不发布到 CDN）
│   │                            # 用于辅助开发、运维、自动化等场景
│   └── export-wsl.ps1           # 导出 WSL 发行版为 .tar.gz 备份
│
└── www/                         # 发布目录（合并到 main 后自动发布到 CDN）
    ├── _headers                 # CDN 响应头配置
    │
    ├── api/                     # API 数据端点
    │   └── install/             # "安装"页面使用的数据
    │       └── online-distros   # 在线发行版镜像源列表
    │
    └── scripts/                 # CDN 分发的脚本（软件在线调用）
        └── home/                # "主页"使用的脚本
            └── distro-cleanup.sh         # 发行版清理脚本
```

### 目录说明

| 目录 | 用途 | 发布到 CDN |
|:---|:---|:---:|
| `documents/` | 开发文档、数据规范、调试指南 | 否 |
| `scripts/` | 仓库级工具脚本，辅助开发/运维/自动化 | 否 |
| `www/` | 软件在线调用的数据和脚本，PR 合入后自动发布 | 是 |

---

## 仓库工具脚本 (`scripts/`)

该目录存放仓库级别的工具脚本，**不会发布到 CDN**，仅供开发者或仓库维护者在本地使用。它们通常用于辅助开发、运维、自动化等场景，例如配合 **WSL Dashboard 的任务调度器 (Task Scheduler)** 定时执行备份任务。

### 导出 WSL 发行版 (`export-wsl.ps1`)

> **适用平台：** Windows（PowerShell）
> **依赖：** [WSL](https://learn.microsoft.com/windows/wsl/) 已安装

将指定的 WSL 发行版导出为 `.tar.gz` 备份文件，文件名自动追加时间戳，避免覆盖。

**使用方式：**

1. 编辑脚本顶部配置区，填写要导出的发行版名称和目标目录：
   ```powershell
   $DistroNames = @(
       "Ubuntu-22.04"
       "Debian"
   )
   $ExportDir = "D:\WSL-Exports"
   ```
2. 直接运行脚本（无需管理员权限）：
   ```powershell
   .\scripts\export-wsl.ps1
   ```
3. 导出的文件格式：`Ubuntu-22.04_20260702_143022.tar.gz`

**工作原理：** 脚本会先执行 `wsl --shutdown` 停止所有 WSL 实例，然后逐一导出并显示文件大小。

### 贡献脚本

欢迎通过 Pull Request 向 `scripts/` 目录提交新的工具脚本。提交时请注意：

- 脚本需有清晰的注释说明用途和使用方式
- 如果依赖外部工具（如 `wsl.exe`），请在注释中注明
- 建议在脚本开头提供可配置的变量区域，方便他人直接修改使用

---

## 发布目录 (`www/`)

该目录是仓库的核心输出——`main` 分支的 `www/` 目录内容会**自动发布到 CDN**，通过 `https://api3.wslui.com` 域名访问。WSL Dashboard 软件在线调用的数据和脚本均来源于此。

> 目录结构直接映射为 URL 路径，例如 `www/api/install/online-distros` 可通过 `https://api3.wslui.com/api/install/online-distros` 访问。

`www/` 下目前包含两类内容：

| 路径 | 用途 | 调用方 |
|:---|:---|:---|
| `www/api/install/online-distros` | 在线发行版镜像源数据 | WSL Dashboard - Install 页 |
| `www/scripts/home/distro-cleanup.sh` | 发行版清理脚本（在 WSL 内以 root 执行） | WSL Dashboard - 压缩发行版 |

通过 PR 修改 `www/` 下的文件并合并到 `main` 后，CDN 内容会自动更新，无需手动部署。

### URL 映射

| 文件路径 | 访问 URL | 用途 |
|:---|:---|:---|
| `www/api/install/online-distros` | `https://api3.wslui.com/api/install/online-distros` | Install 页 - 在线发行版(镜像) 源数据 |
| `www/scripts/home/distro-cleanup.sh` | `https://api3.wslui.com/scripts/home/distro-cleanup.sh` | Home 页 - 压缩发行版 - 清理脚本 |

### 缓存策略

| 路径 | CDN 缓存 | 浏览器缓存 | Content-Type |
|:---|:---|:---|:---|
| `/api/*` | 2 分钟 | 1 分钟 | `application/json` |
| `/scripts/*` | 5 分钟 | 3 分钟 | `application/x-sh` |

---

## 如何编辑

### 1. 编辑镜像源数据 (`online-distros`)

该文件是 JSON 格式，定义了 WSL 可安装的在线发行版及其镜像源。

> 可用镜像站列表参考 [documents/zh-CN/mirrors.yml](documents/zh-CN/mirrors.yml)，其中 `enabled: false` 的站点存在访问限制，不建议使用。

> **格式要求**：并非所有发行版源文件都能被 WSL 导入，需要同时满足以下条件：
> - **架构**：仅支持 `amd64`（x86_64），不支持 `arm64` 等其他架构
> - **文件格式**：
>   - `tar.gz` — 常见的 rootfs 压缩包
>   - `tar.xz` — xz 压缩的 rootfs 包
>   - `wsl` — WSL 专用发行版包格式
> - **版本号**：遵循 `MAJOR.MINOR.PATCH` 语义化版本规范。当同一 Minor 版本存在多个 Patch 版本时，仅收录最新的一个（如 `20.04.5` 与 `20.04.6` 共存，只保留 `20.04.6`）
>
> 添加新的镜像源时，请确认架构为 `amd64` 且文件后缀属于上述格式。其他架构（如 `arm64`）或格式（如 `.iso`、`.qcow2`、`.img`）无法被 WSL 使用。

**文件格式：**

```json
{
  "err": 0,
  "msg": "success",
  "data": {
    "update_time": "2026-01-01T00:00:00Z",
    "distros": [
      {
        "name": "Ubuntu",
        "version": "24.04",
        "sources": [
          {
            "url": "https://mirrors.example.com/ubuntu-24.04-server-cloudimg-amd64-wsl.rootfs.tar.gz",
            "mirror": "example",
            "format": "tar.gz",
            "last_modified": "2026-01-01T00:00:00Z"
          }
        ]
      }
    ]
  }
}
```

**字段说明：**

| 字段 | 类型 | 说明 |
|:---|:---|:---|
| `err` | `number` | 错误码，成功时为 `0` |
| `msg` | `string` | 消息文本，成功时为 `"success"` |
| `data.update_time` | `string` | 数据更新时间（ISO 8601 格式） |
| `data.distros` | `array` | 发行版列表 |
| `distros[].name` | `string` | 发行版名称（如 `Ubuntu`、`Alpine`） |
| `distros[].version` | `string` | 版本号 |
| `distros[].sources` | `array` | 该发行版的镜像源列表 |
| `sources[].url` | `string` | 镜像下载地址 |
| `sources[].mirror` | `string` | 镜像站标识（如 `sjtu`、`tencent`） |
| `sources[].format` | `string` | 文件格式（`tar.gz`、`tar.xz` 等） |
| `sources[].last_modified` | `string` | 最后修改时间（可选） |

#### 数据来源

`online-distros` 数据由社区维护，经过架构、格式、版本、镜像数量等多轮筛选后输出标准化 JSON。

详细的数据筛选规范请参阅 [数据来源与筛选规则](documents/zh-CN/data-source.md)。

---

### 2. 编辑清理脚本 (`distro-cleanup.sh`)

该脚本在 WSL 发行版内以 `root` 身份执行，用于清理临时文件和包缓存。

**要求：**
- 文件必须是有效的 Shell 脚本（`.sh` 扩展名）
- 脚本应兼容多种 Linux 发行版（Debian、Fedora、Arch、openSUSE、Alpine 等）
- 使用 `command -v` 自动检测可用的包管理器
- 不要删除用户数据，只清理系统临时文件和包缓存

**参考示例：** 查看当前仓库中的 `www/scripts/home/distro-cleanup.sh`

---

## 本地调试

克隆本仓库后，可以通过配置文件在本地测试修改效果，无需提交到远程仓库。

> 完整的调试配置说明请参考 [documents/zh-CN/debug-config.md](documents/zh-CN/debug-config.md)。

### 1. 创建调试配置文件

在以下位置创建 `debug.toml` 文件：

```
Windows:  C:\Users\<你的用户名>\.wsldashboard\debug.toml
```

### 2. 配置内容

```toml
[install]
# 指向本地的 online-distros 文件
online-distros = 'D:\develop\wsl-community\www\api\install\online-distros'

[distro]
# 指向本地的 distro-cleanup.sh 文件
cleanup-script = 'D:\develop\wsl-community\www\scripts\home\distro-cleanup.sh'
```

> 将路径替换为你本仓库的实际路径。

### 3. 测试镜像源数据

1. 编辑 `www/api/install/online-distros` 文件
2. 启动 WSL Dashboard
3. 进入 **创建新实例** → 选择 **在线发行版（镜像）**
4. 软件将从本地文件加载发行版列表
5. 查看日志确认：
   ```
   [Debug] install.online-distros is set to '...', using local file instead of network
   [Debug] Parsed MirrorListResponse from local file: N distros
   ```

### 4. 测试清理脚本

1. 编辑 `www/scripts/home/distro-cleanup.sh` 文件
2. 启动 WSL Dashboard
3. 对任意已安装的发行版执行 **压缩** 操作
4. 在清理阶段，软件将执行本地脚本
5. 查看日志确认：
   ```
   [Debug] distro.cleanup-script is set to '...', skipping wslui_helper_distro() API call
   Executing local cleanup script from: ...
   ```

### 5. 查看日志

调试配置相关的日志级别：
- `INFO`：正常流程（配置加载、使用本地文件）
- `WARN`：异常情况（文件不存在、解析失败）

常见日志：

| 日志内容 | 说明 |
|:---|:---|
| `debug.toml not found at <path>, using defaults` | 配置文件不存在，使用默认行为 |
| `Loaded debug.toml from <path>` | 配置文件加载成功 |
| `Local mirror JSON file not found: <path>` | 本地 JSON 文件路径错误 |
| `Failed to parse MirrorListResponse` | JSON 文件格式错误 |

### 6. 恢复默认行为

调试完成后，删除或清空 `debug.toml` 即可恢复从网络获取数据：

```toml
[install]
online-distros = ''

[distro]
cleanup-script = ''
```

或者直接删除整个文件。

---

## 提交流程

1. **Fork** 本仓库到你的 GitHub 账号
2. **Clone** 到本地：
   ```bash
   git clone https://github.com/<你的用户名>/wsl-community.git
   ```
3. **创建分支**：
   ```bash
   git checkout -b feat/add-new-distro
   ```
4. **编辑文件**：修改 `www/` 目录下的数据或脚本
5. **本地调试**：按照上述「本地调试」步骤验证修改
6. **提交并推送**：
   ```bash
   git add www/api/install/online-distros
   git commit -m "feat: add Ubuntu 24.10 mirror source"
   git push origin feat/add-new-distro
   ```
7. **创建 Pull Request**：目标分支为 `main`
8. **合并后自动部署**：PR 合并到 `main` 后，会自动发布到 `https://api3.wslui.com`

---

## 注意事项

- **不要提交敏感信息**：本仓库是公开的，所有内容对所有人可见
- **JSON 格式校验**：修改 `online-distros` 后，建议用 JSON 校验工具检查格式
- **JSON 保持格式化**：JSON 文件必须使用带缩进的格式化输出（4 空格缩进），**不要使用压缩/去空格的 JSON**。这样 git diff 才能清晰展示行级变更，方便代码审查
- **统一缩进**：所有文件使用 **4 个空格**缩进，禁止使用 Tab（项目已配置 `.editorconfig`，主流编辑器会自动遵循）
- **脚本兼容性**：清理脚本应兼容主流 Linux 发行版
- **URL 不要加扩展名**：访问时使用 `/api/install/online-distros`，不是 `.json`
- **发行版排序规则**：`online-distros` 文件中的 `data.distros` 数组必须按以下规则排序：
  - 主排序键：`name`（发行版名称），**降序**（Z → A）
  - 次排序键：`version`（版本号），**降序**（高版本在前）
  - 示例顺序：`Ubuntu 24.04` → `Ubuntu 22.04` → `Ubuntu 20.04` → ... → `Amazon Linux 2023` → `Amazon Linux 2` → `AlmaLinux 10` → `Alpine 3.24` → `Alpine 3.22`
  - 这样贡献者可以快速确定新发行版应该插入的位置，保持文件结构清晰，便于代码审查
- **镜像源排序规则**：每个发行版的 `sources` 数组（`data.distros[*].sources[*]`）必须按 `mirror` 字段**降序**排列（Z → A），这样新增镜像源时可以快速确定插入位置

---

## 许可证

基于 [GPLv3 许可证](LICENSE) 开源。
