# 调试模式 (Debug Mode)

本文档介绍 WSL Dashboard 的调试配置文件 `debug.toml`，用于在开发和测试阶段加载本地文件，绕过网络请求。

## 配置文件位置

```
~/.wsldashboard/debug.toml
```

在 Windows 系统中通常为：`C:\Users\<用户名>\.wsldashboard\debug.toml`

该文件为可选配置。如果文件不存在，软件将使用默认行为（从网络获取数据），不会报错。

---

## 配置项说明

### `[install]` - 安装相关调试

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `online-distros` | `string` | 本地镜像列表 JSON 文件的绝对路径。设置后，在线发行版安装将从该本地文件读取数据，而非从网络获取。 |

**作用范围：** 创建新实例时，选择"在线发行版（镜像）"来源，加载可安装的发行版列表。

**行为逻辑：**
1. 检查 `online-distros` 是否为空
2. 如果非空 → 从本地 JSON 文件加载 `MirrorListResponse` 数据
3. 如果为空 → 从网络 API 正常获取镜像列表

### `[distro]` - 发行版操作调试

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `cleanup-script` | `string` | 本地清理脚本（`.sh` 文件）的绝对路径。设置后，压缩操作的清理阶段将执行该本地脚本，而非从网络下载默认清理脚本。 |

**作用范围：** 压缩 VHDX 磁盘时，在清理临时文件阶段使用。

**行为逻辑：**
1. 检查 `cleanup-script` 是否为空
2. 如果非空 → 验证文件是否存在且为 `.sh` 文件，然后在 WSL 发行版内执行该脚本
3. 如果为空 → 从网络下载默认清理脚本并执行

---

## 配置文件示例

```toml
[install]
online-distros = 'D:\develop\wsl-community\www\api\install\online-distros'

[distro]
cleanup-script = 'D:\develop\wsl-community\www\scripts\home\distro-cleanup.sh'
```

---

## 本地镜像 JSON 文件格式

`online-distros` 指向的 JSON 文件需要符合 `ApiResponse<MirrorListResponse>` 结构：

```json
{
  "err": 0,
  "msg": "success",
  "data": {
    "update_time": "2026-01-01",
    "distros": [
      {
        "name": "Ubuntu",
        "version": "24.04",
        "sources": [
          {
            "url": "https://mirror.example.com/ubuntu-24.04.tar.gz",
            "mirror": "mirror.example.com",
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
- `err`：错误码，成功时为 `0`
- `msg`：消息文本
- `data.update_time`：数据更新时间
- `data.version`：数据版本
- `data.distros`：发行版列表
  - `name`：发行版名称
  - `version`：版本号
  - `arch`：架构（如 `x64`、`arm64`）
  - `sources`：下载源列表
    - `url`：下载地址
    - `mirror`：镜像站名称
    - `format`：文件格式（如 `tar.gz`、`wsl`）
    - `file_size`：文件大小（字节，可选）
    - `last_modified`：最后修改时间（可选）

---

## 本地清理脚本要求

`cleanup-script` 指向的脚本文件需要满足以下条件：

1. 文件必须存在
2. 文件扩展名必须为 `.sh`
3. 脚本将在 WSL 发行版内以 `root` 用户身份执行
4. 脚本内容应为有效的 Shell 脚本，用于清理临时文件和包缓存

---

## 关键日志输出

软件在处理调试配置时会输出以下日志，可通过日志文件或控制台查看：

### 配置加载阶段

| 日志级别 | 日志内容 | 说明 |
|----------|----------|------|
| `INFO` | `[DebugConfig] debug.toml not found at <path>, using defaults` | 配置文件不存在，使用默认值 |
| `INFO` | `[DebugConfig] Loaded debug.toml from <path>: install.online-distros='<value>'` | 配置文件加载成功 |
| `WARN` | `[DebugConfig] Failed to parse debug.toml at <path>: <error>. Using defaults.` | 配置文件解析失败 |
| `WARN` | `[DebugConfig] Failed to read debug.toml at <path>: <error>. Using defaults.` | 配置文件读取失败 |

### 在线发行版加载阶段（`online-distros`）

| 日志级别 | 日志内容 | 说明 |
|----------|----------|------|
| `INFO` | `[Debug] install.online-distros is set to '<path>', using local file instead of network` | 使用本地文件加载镜像列表 |
| `INFO` | `[Debug] install.online-distros is empty, fetching mirror distros from network` | 配置为空，从网络获取 |
| `INFO` | `[Debug] Parsed MirrorListResponse from local file: <N> distros` | 本地文件解析成功，包含 N 个发行版 |
| `WARN` | `[Debug] Local mirror JSON file not found: <path>` | 本地 JSON 文件不存在 |
| `WARN` | `[Debug] Failed to parse MirrorListResponse from '<path>': <error>` | 本地 JSON 文件解析失败 |
| `WARN` | `[Debug] Failed to read local mirror JSON '<path>': <error>` | 本地 JSON 文件读取失败 |

### 清理脚本阶段（`cleanup-script`）

| 日志级别 | 日志内容 | 说明 |
|----------|----------|------|
| `INFO` | `[Debug] distro.cleanup-script is set to '<path>', skipping wslui_helper_distro() API call` | 使用本地清理脚本，跳过网络 API 调用 |
| `INFO` | `Executing local cleanup script from: <path>` | 开始执行本地清理脚本 |
| `WARN` | `Local cleanup script failed: <error>` | 本地清理脚本执行失败 |

### 用户界面提示（i18n 键值）

当调试配置出现问题时，软件会在界面上显示以下提示信息：

| i18n 键 | 中文 | 英文 |
|----------|------|------|
| `debug.mirrors_file_not_found` | [Debug] 指定的本地镜像 JSON 文件不存在。 | [Debug] The specified local mirror JSON file does not exist. |
| `debug.mirrors_parse_failed` | [Debug] 无法解析本地镜像 JSON 文件。 | [Debug] Could not parse the local mirror JSON file. |
| `debug.cleanup_script_invalid` | [Debug] 指定的本地清理脚本不存在或不是 .sh 文件。 | [Debug] The specified local cleanup script is missing or not a .sh file. |

---

## 使用场景

### 场景 1：测试在线发行版安装流程

1. 准备一个符合格式要求的本地 JSON 文件（参考上述格式）
2. 在 `debug.toml` 中配置 `online-distros` 指向该文件
3. 启动软件，进入"创建新实例" → 选择"在线发行版（镜像）"
4. 软件将从本地文件加载发行版列表，而非从网络获取

### 场景 2：测试压缩清理脚本

1. 准备一个本地 `.sh` 清理脚本
2. 在 `debug.toml` 中配置 `cleanup-script` 指向该脚本
3. 对任意已安装的发行版执行压缩操作
4. 软件将在清理阶段执行本地脚本，而非从网络下载

---

## 相关源码文件

| 文件路径 | 说明 |
|----------|------|
| `src/config/debug.rs` | 调试配置结构体定义和加载逻辑 |
| `src/app/state.rs` | 应用状态中持有 `debug_config` 字段 |
| `src/ui/handlers/distro/install.rs` | 安装流程中读取 `online-distros` 配置 |
| `src/ui/handlers/distro/compress.rs` | 压缩流程中读取 `cleanup-script` 配置 |
| `src/ui/data.rs` | `load_local_mirror_distros()` 函数，本地镜像加载实现 |
| `src/wsl/ops/compress.rs` | `cleanup_temp_files()` 函数，清理脚本执行逻辑 |
