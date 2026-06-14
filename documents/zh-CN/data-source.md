# 数据来源与筛选规范

本文档说明 `online-distros` 数据的筛选规范、原则及底层逻辑。

数据由社区维护，经过严格的筛选流程后输出标准化 JSON，最终自动部署到 CDN。

---

## 一、筛选原则与规范

### 1. 架构筛选
仅保留 **amd64** (x86_64) 架构。忽略 `arm64`、`armhf` 等其他架构，因为这些架构的镜像不适合当前主流的 WSL 使用场景。

### 2. 文件格式筛选
WSL 仅支持导入特定的 RootFS 文件格式。为了确保用户下载的镜像能够直接使用，我们严格筛选以下格式：
*   **支持格式**: `tar.gz`, `tar.xz`, `.wsl`
*   **禁止格式**: `.squashfs` (SquashFS 格式，无法被 WSL 导入)
*   **排除类型**: `.iso`, `.img`, `.qcow2`, `.vmdk` 等物理介质或虚拟机格式

### 3. 镜像数量筛选
为了确保服务的高可用性和下载速度，要求**同一发行版的同一版本至少有 2 个可用的镜像源**。如果一个版本只有 1 个镜像源可用，则该版本会被剔除，以避免单点故障导致下载失败。

### 4. 版本筛选规则

#### Ubuntu - 仅 LTS 版本
Ubuntu 的长期支持 (LTS) 版本仅使用偶数版本号（如 20.04, 22.04, 24.04）。中间的非 LTS 版本（如 25.04, 25.10）会被主动跳过，因为它们的生命周期较短，且不适合作为稳定的开发环境。

#### 开发代号到版本号的映射
部分发行版（如 Debian, Ubuntu）在官方源中使用开发代号（代号）命名文件。我们维护了一份映射表，将这些代号转换为用户友好的数字版本号。
*   **Debian**: `bookworm` -> `12`, `trixie` -> `13`, `forky` -> `14`
*   **Ubuntu**: `focal` -> `20.04`, `jammy` -> `22.04`, `noble` -> `24.04`

#### 版本去重与合并
对于某些发行版的特定版本（如 Ubuntu 20.04），可能存在多个补丁版本（如 20.04.1, 20.04.2, 20.04.5）。我们的原则是：**仅保留该 Minor 版本下的最新 Patch 版本**。同时，我们会合并来自不同数据源（如常规镜像站和 LXC Images）的同一发行版同一版本的镜像，去除重复项。

#### 生命周期 (EOL) 控制
我们不收录已经或即将停止维护 (End Of Life) 的发行版版本。此规则基于各发行版官方的发布与维护周期表来执行。

### 5. 文件可用性校验
最终产出的每个镜像 URL 都会经过 HTTP HEAD 请求的校验，以确保文件真实存在且可以下载。校验失败的镜像会被标记为不可用并剔除。

---

## 二、当前支持的发行版清单

以下是经过上述规则筛选后，在清单中保留的发行版及版本：

| 发行版 | 保留的版本 | 核心排除原因（仅供参考） |
| :--- | :--- | :--- |
| **Ubuntu** | 20.04, 22.04, 24.04 | 非 LTS 版本已排除 |
| **Debian** | 12 (Bookworm), 13 (Trixie) | 旧版本 (<=11) 已排除 |
| **Rocky Linux** | 9, 10 | 旧版本 (<=8) 已排除 |
| **openSUSE** | 15.6 (Leap), Tumbleweed | 旧版本 (<15) 已排除 |
| **Fedora** | 42 | 旧版本 (<=41) 已排除 |
| **Alpine** | 3.22 | 旧版本 (<=3.21) 已排除 |
| **CentOS Stream** | 10, 9 | 旧版本 (<=8) 已排除 |
| **Oracle Linux** | 9, 10 | 旧版本 (<=8) 已排除 |
| **AlmaLinux** | 10 | 旧版本 (<=9) 已排除 |

**已排除的发行版 (不收录)**:
为了保证数据的质量和用户体验，以下发行版因各种原因被完全排除，不会出现在清单中：
*   ALT Linux, Arch Linux, Kali, Linux Mint, NixOS, Devuan, Slackware, Void Linux: 这些发行版的官方 RootFS 文件格式主要为 SquashFS，不适用于 WSL 环境。
*   Amazon Linux: 这是 AWS 云环境专用的发行版，在 WSL 场景下不常见。
*   BusyBox, openEuler, Plamo: 发行版特性过于特殊（BusyBox 过于精简）、社区极小或兼容性未得到广泛验证。
*   OpenWrt: 这是一款路由器/嵌入式系统专用的发行版，不适合作为桌面或开发环境使用。

---

## 三、数据源 (Data Sources)

我们的数据来源主要分为两类，均来自官方或社区维护的镜像站：

### 1. 常规 Linux 镜像站
这是主要的数据来源，包含国内多家高校和云厂商的镜像站，提供了官方发布的 WSL 格式或 RootFS 格式文件。

| 镜像站 | 维护方 | 状态 |
| :--- | :--- | :--- |
| mirrors.aliyun.com | 阿里云 | 启用 |
| mirrors.tuna.tsinghua.edu.cn | 清华大学 | 启用 |
| mirrors.163.com | 网易 | 启用 |
| mirrors.bfsu.edu.cn | 北京外国语大学 | 启用 |
| mirrors.nju.edu.cn | 南京大学 | 启用 |
| mirrors.sjtug.sjtu.edu.cn | 上海交通大学 | 启用 |
| mirrors.hit.edu.cn | 哈尔滨工业大学 | 启用 |
| mirrors.zju.edu.cn | 浙江大学 | 启用 |
| mirrors.hust.edu.cn | 华中科技大学 | 启用 |
| mirrors.cloud.tencent.com | 腾讯云 | 启用 |
| mirrors.huaweicloud.com | 华为云 | 启用 |
| mirrors.volces.com | 火山引擎 | 启用 |
| mirrors.sohu.com | 搜狐 | 启用 |

### 2. LXC Images 镜像站
LXC (Linux 容器) 项目维护的官方镜像站，提供了大量标准化的 RootFS 文件。这些文件经过验证，可以直接用于 WSL 的 `wsl --import` 命令。我们会定期从国内的 LXC 镜像站同步这些数据。

| 镜像站 URL | 维护方 | 状态 |
| :--- | :--- | :--- |
| mirrors.tuna.tsinghua.edu.cn/lxc-images/ | 清华大学 | 启用 |
| mirrors.bfsu.edu.cn/lxc-images/ | 北京外国语大学 | 启用 |
| mirrors.nju.edu.cn/lxc-images/ | 南京大学 | 启用 |
| mirrors.cloud.tencent.com/lxc-images/ | 腾讯云 | 启用 |
| mirrors.huaweicloud.com/lxc-images/ | 华为云 | 启用 |
