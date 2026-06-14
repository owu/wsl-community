# Data Sources and Filtering Specifications

This document describes the filtering specifications, rules, and underlying logic for the `online-distros` data.

The data is community-maintained and output as standardized JSON after strict filtering processes, which is then automatically deployed to the CDN.

---

## I. Filtering Principles and Specifications

### 1. Architecture Filtering
Only the **amd64** (x86_64) architecture is retained. Other architectures like `arm64` and `armhf` are ignored because their images are not suitable for the mainstream WSL usage scenarios.

### 2. File Format Filtering
WSL only supports importing RootFS files in specific formats. To ensure user-downloaded images can be used directly, we strictly filter for the following formats:
*   **Supported Formats**: `tar.gz`, `tar.xz`, `.wsl`
*   **Prohibited Formats**: `.squashfs` (SquashFS format, cannot be imported by WSL)
*   **Excluded Types**: `.iso`, `.img`, `.qcow2`, `.vmdk` and other physical media or virtual machine formats.

### 3. Mirror Count Filtering
To ensure high availability and download speed, **each version of a distro must have at least 2 available mirror sources**. If a version has only one mirror source, it will be excluded to avoid download failures caused by single points of failure.

### 4. Version Filtering Rules

#### Ubuntu - LTS Versions Only
Ubuntu's Long-Term Support (LTS) versions use even minor version numbers (e.g., 20.04, 22.04, 24.04). Non-LTS intermediate versions (e.g., 25.04, 25.10) are actively skipped because they have shorter lifecycles and are not suitable for stable development environments.

#### Development Codename to Version Number Mapping
Some distros (like Debian and Ubuntu) use development codenames (codenames) to name files in their official sources. We maintain a mapping table to convert these codenames into user-friendly numeric version numbers.
*   **Debian**: `bookworm` -> `12`, `trixie` -> `13`, `forky` -> `14`
*   **Ubuntu**: `focal` -> `20.04`, `jammy` -> `22.04`, `noble` -> `24.04`

#### Version Deduplication and Merging
For certain versions of distros (like Ubuntu 20.04), there may be multiple patch versions (e.g., 20.04.1, 20.04.2, 20.04.5). Our principle is to **only keep the latest Patch version under that Minor version**. At the same time, we merge mirrors of the same version of the same distro from different data sources (e.g., regular mirror sites and LXC Images) and remove duplicates.

#### End-of-Life (EOL) Control
We do not include distro versions that are or are about to be end-of-life. This rule is implemented based on the official release and maintenance cycle schedules of each distro.

### 5. File Availability Check
Each mirror URL in the final output is verified via an HTTP HEAD request to ensure the file actually exists and can be downloaded. Mirrors that fail the verification are marked as unavailable and removed.

---

## II. Currently Supported Distros

The following distros and versions are retained in the list after filtering according to the above rules:

| Distro | Retained Versions | Core Exclusion Reasons (for reference only) |
| :--- | :--- | :--- |
| **Ubuntu** | 20.04, 22.04, 24.04 | Non-LTS versions excluded |
| **Debian** | 12 (Bookworm), 13 (Trixie) | Old versions (<=11) excluded |
| **Rocky Linux** | 9, 10 | Old versions (<=8) excluded |
| **openSUSE** | 15.6 (Leap), Tumbleweed | Old versions (<15) excluded |
| **Fedora** | 42 | Old versions (<=41) excluded |
| **Alpine** | 3.22 | Old versions (<=3.21) excluded |
| **CentOS Stream** | 10, 9 | Old versions (<=8) excluded |
| **Oracle Linux** | 9, 10 | Old versions (<=8) excluded |
| **AlmaLinux** | 10 | Old versions (<=9) excluded |

**Excluded Distros (Not Included)**:
To ensure data quality and user experience, the following distros are completely excluded for various reasons and will not appear in the list:
*   ALT Linux, Arch Linux, Kali, Linux Mint, NixOS, Devuan, Slackware, Void Linux: The official RootFS file format of these distros is mainly SquashFS, which is not suitable for WSL environments.
*   Amazon Linux: This is a distro specifically for the AWS cloud environment and is not common in WSL scenarios.
*   BusyBox, openEuler, Plamo: These distros have special characteristics (BusyBox is too minimal), have very small communities, or their compatibility has not been widely verified.
*   OpenWrt: This is a distro designed specifically for routers/embedded systems and is not suitable as a desktop or development environment.

---

## III. Data Sources

Our data sources are primarily divided into two categories, both coming from official or community-maintained mirror sites:

### 1. Regular Linux Mirror Sites
This is the primary data source, consisting of mirror sites maintained by several universities and cloud providers in China. They provide officially released WSL format or RootFS format files.

| Mirror Site | Maintainer | Status |
| :--- | :--- | :--- |
| mirrors.aliyun.com | Alibaba Cloud | Enabled |
| mirrors.tuna.tsinghua.edu.cn | Tsinghua University | Enabled |
| mirrors.163.com | NetEase | Enabled |
| mirrors.bfsu.edu.cn | Beijing Foreign Studies University | Enabled |
| mirrors.nju.edu.cn | Nanjing University | Enabled |
| mirrors.sjtug.sjtu.edu.cn | Shanghai Jiao Tong University | Enabled |
| mirrors.hit.edu.cn | Harbin Institute of Technology | Enabled |
| mirrors.zju.edu.cn | Zhejiang University | Enabled |
| mirrors.hust.edu.cn | Huazhong University of Science and Technology | Enabled |
| mirrors.cloud.tencent.com | Tencent Cloud | Enabled |
| mirrors.huaweicloud.com | Huawei Cloud | Enabled |
| mirrors.volces.com | Volcengine | Enabled |
| mirrors.sohu.com | Sohu | Enabled |

### 2. LXC Images Mirror Sites
The LXC (Linux Container) project maintains an official mirror site that provides a large number of standardized RootFS files. These files have been verified and can be directly used for the WSL `wsl --import` command. We periodically synchronize this data from domestic LXC mirror sites.

| Mirror Site URL | Maintainer | Status |
| :--- | :--- | :--- |
| mirrors.tuna.tsinghua.edu.cn/lxc-images/ | Tsinghua University | Enabled |
| mirrors.bfsu.edu.cn/lxc-images/ | Beijing Foreign Studies University | Enabled |
| mirrors.nju.edu.cn/lxc-images/ | Nanjing University | Enabled |
| mirrors.cloud.tencent.com/lxc-images/ | Tencent Cloud | Enabled |
| mirrors.huaweicloud.com/lxc-images/ | Huawei Cloud | Enabled |
