# wsl-community

[English](README.md) | [中文](README.zh-CN.md)

**Community-maintained scripts and data resources for [WSL Dashboard](https://github.com/owu/wsl-dashboard).**

This repository hosts the scripts and JSON data endpoints required by WSL Dashboard. Changes merged into the `main` branch are automatically published to CDN for online access by the software.

> **Note**: This is a **data & scripts** repository. For the main application, please visit [wsl-dashboard](https://github.com/owu/wsl-dashboard).



## Architecture Overview

```
wsl-community repository
       │
       │  Submit PR to merge changes
       ▼
  Auto-publish to CDN
       │
       │  WSL Dashboard software calls
       ▼
    User device
```

The `www/` directory of the `main` branch is automatically published to CDN, accessible via the `https://api3.wslui.com` domain. The directory structure maps directly to URL paths.

---

## Directory Structure

```
wsl-community/
├── README.md                    # English (not published)
├── README.zh-CN.md              # Chinese (not published)
├── LICENSE                      # GPLv3 License (not published)
│
├── documents/                   # Development docs (not published to CDN)
│   ├── zh-CN/                   # Chinese docs
│   │   ├── data-source.md       # Data source and filtering rules
│   │   ├── debug-config.md      # Debug configuration guide
│   │   └── mirrors.yml          # Mirror sites reference list
│   └── en/                      # English docs
│       ├── data-source.md
│       ├── debug-config.md
│       └── mirrors.yml
│
├── scripts/                     # Repository-level utility scripts (not published to CDN)
│   │                            # For development, operations, automation, etc.
│   └── export-wsl.ps1           # Export WSL distros to .tar.gz backup
│
└── www/                         # Publish directory (auto-published to CDN on main)
    ├── _headers                 # CDN response headers
    │
    ├── api/                     # API data endpoints
    │   └── install/             # Data for "Install" page
    │       └── online-distros   # Online distro mirror list
    │
    └── scripts/                 # CDN-delivered scripts (called by software online)
        └── home/                # Scripts for "Home" page
            └── distro-cleanup.sh         # Distro cleanup script
```

### Directory Purposes

| Directory | Purpose | Published to CDN |
|:---|:---|:---:|
| `documents/` | Development docs, data specs, debug guides | No |
| `scripts/` | Repository-level utility scripts for dev/ops/automation | No |
| `www/` | Data and scripts consumed by the software, auto-published on PR merge | Yes |

---

## Repository Utility Scripts (`scripts/`)

This directory contains repository-level utility scripts that are **not published to CDN**. They are intended for local use by developers and maintainers — for development, operations, automation, etc. For example, you can schedule them via the **WSL Dashboard Task Scheduler** to run backups on a recurring basis.

### Export WSL Distros (`export-wsl.ps1`)

> **Platform:** Windows (PowerShell)
> **Prerequisite:** [WSL](https://learn.microsoft.com/windows/wsl/) installed

Exports specified WSL distributions to `.tar.gz` backup files with an auto-generated timestamp in the filename to avoid overwrites.

**Usage:**

1. Edit the config section at the top of the script to set the distro names and target directory:
   ```powershell
   $DistroNames = @(
       "Ubuntu-22.04"
       "Debian"
   )
   $ExportDir = "D:\WSL-Exports"
   ```
2. Run the script directly (no admin rights required):
   ```powershell
   .\scripts\export-wsl.ps1
   ```
3. Exported file format: `Ubuntu-22.04_20260702_143022.tar.gz`

**How it works:** The script runs `wsl --shutdown` to stop all WSL instances, then exports each distro sequentially and displays the file size.

### Contributing Scripts

Feel free to submit Pull Requests adding new utility scripts to `scripts/`. Please keep in mind:

- Include clear comments explaining the purpose and usage
- Note any external dependencies (e.g., `wsl.exe`) in comments
- Provide configurable variables at the top of the script for easy customization

---

## Publish Directory (`www/`)

This is the core output of the repository — the `www/` directory on the `main` branch is **automatically published to CDN** and served via `https://api3.wslui.com`. All data and scripts consumed online by WSL Dashboard come from here.

> Directory structure maps directly to URL paths. For example, `www/api/install/online-distros` is accessible at `https://api3.wslui.com/api/install/online-distros`.

`www/` currently contains two types of content:

| Path | Purpose | Consumed By |
|:---|:---|:---|
| `www/api/install/online-distros` | Online distro mirror source data | WSL Dashboard - Install page |
| `www/scripts/home/distro-cleanup.sh` | Distro cleanup script (runs as root inside WSL) | WSL Dashboard - Compress distro |

When a PR modifying files under `www/` is merged to `main`, the CDN content updates automatically — no manual deployment needed.

### URL Mapping

| File Path | Access URL | Purpose |
|:---|:---|:---|
| `www/api/install/online-distros` | `https://api3.wslui.com/api/install/online-distros` | Install page - Online distro (mirror) source data |
| `www/scripts/home/distro-cleanup.sh` | `https://api3.wslui.com/scripts/home/distro-cleanup.sh` | Home page - Compress distro - Cleanup script |

### Cache Policy

| Path | CDN Cache | Browser Cache | Content-Type |
|:---|:---|:---|:---|
| `/api/*` | 2 minutes | 1 minute | `application/json` |
| `/scripts/*` | 5 minutes | 3 minutes | `application/x-sh` |

---

## How to Edit

### 1. Edit Mirror Source Data (`online-distros`)

This file is in JSON format and defines the online distros and their mirror sources available for WSL installation.

> For available mirror sites, refer to [documents/en/mirrors.yml](documents/en/mirrors.yml). Sites with `enabled: false` have access restrictions and are not recommended.

> **Format Requirements**: Not all distro source files can be imported into WSL. The following conditions must be met:
> - **Architecture**: Only `amd64` (x86_64) is supported. `arm64` and other architectures are not supported.
> - **File format**:
>   - `tar.gz` — Common rootfs archive
>   - `tar.xz` — xz-compressed rootfs archive
>   - `wsl` — WSL-specific distro package format
> - **Version**: Follows `MAJOR.MINOR.PATCH` semantic versioning. When multiple Patch versions exist for the same Minor version, only the latest one is kept (e.g., if both `20.04.5` and `20.04.6` exist, only `20.04.6` is included)
>
> When adding new mirror sources, ensure the architecture is `amd64` and the file extension matches one of the formats above. Other architectures (e.g., `arm64`) or formats (e.g., `.iso`, `.qcow2`, `.img`) cannot be used by WSL.

**File Format:**

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

**Field Descriptions:**

| Field | Type | Description |
|:---|:---|:---|
| `err` | `number` | Error code, `0` on success |
| `msg` | `string` | Message text, `"success"` on success |
| `data.update_time` | `string` | Data update time (ISO 8601 format) |
| `data.distros` | `array` | Distro list |
| `distros[].name` | `string` | Distro name (e.g., `Ubuntu`, `Alpine`) |
| `distros[].version` | `string` | Version number |
| `distros[].sources` | `array` | Mirror source list for this distro |
| `sources[].url` | `string` | Mirror download URL |
| `sources[].mirror` | `string` | Mirror site identifier (e.g., `sjtu`, `tencent`) |
| `sources[].format` | `string` | File format (`tar.gz`, `tar.xz`, etc.) |
| `sources[].last_modified` | `string` | Last modified time (optional) |

#### Data Source

The `online-distros` data is community-maintained, with multiple filtering stages (architecture, format, version, mirror count) applied before outputting standardized JSON.

For details on the filtering rules, see [Data Source and Filtering Rules](documents/en/data-source.md).

---

### 2. Edit Cleanup Script (`distro-cleanup.sh`)

This script executes as `root` within the WSL distro to clean temporary files and package caches.

**Requirements:**
- Must be a valid Shell script (`.sh` extension)
- Should be compatible with multiple Linux distros (Debian, Fedora, Arch, openSUSE, Alpine, etc.)
- Use `command -v` to auto-detect available package managers
- Do not delete user data; only clean system temporary files and package caches

**Reference:** See `www/scripts/home/distro-cleanup.sh` in this repository

---

## Local Debugging

After cloning this repository, you can test changes locally using a configuration file without pushing to the remote repository.

> For complete debug configuration details, see [documents/en/debug-config.md](documents/en/debug-config.md).

### 1. Create Debug Configuration File

Create a `debug.toml` file at:

```
Windows:  C:\Users\<your username>\.wsldashboard\debug.toml
```

### 2. Configuration Content

```toml
[install]
# Point to local online-distros file
online-distros = 'D:\develop\wsl-community\www\api\install\online-distros'

[distro]
# Point to local distro-cleanup.sh file
cleanup-script = 'D:\develop\wsl-community\www\scripts\home\distro-cleanup.sh'
```

> Replace the paths with your actual repository paths.

### 3. Test Mirror Source Data

1. Edit `www/api/install/online-distros` file
2. Launch WSL Dashboard
3. Go to **Create New Instance** → select **Online Distro (Mirror)**
4. The software will load the distro list from the local file
5. Check logs to confirm:
   ```
   [Debug] install.online-distros is set to '...', using local file instead of network
   [Debug] Parsed MirrorListResponse from local file: N distros
   ```

### 4. Test Cleanup Script

1. Edit `www/scripts/home/distro-cleanup.sh` file
2. Launch WSL Dashboard
3. Execute **Compression** on any installed distro
4. During the cleanup phase, the software will execute the local script
5. Check logs to confirm:
   ```
   [Debug] distro.cleanup-script is set to '...', skipping wslui_helper_distro() API call
   Executing local cleanup script from: ...
   ```

### 5. View Logs

Debug configuration related log levels:
- `INFO`: Normal flow (config loading, using local files)
- `WARN`: Issues (file not found, parse failure)

Common logs:

| Log Message | Description |
|:---|:---|
| `debug.toml not found at <path>, using defaults` | Config file not found, using default behavior |
| `Loaded debug.toml from <path>` | Config file loaded successfully |
| `Local mirror JSON file not found: <path>` | Local JSON file path error |
| `Failed to parse MirrorListResponse` | JSON file format error |

### 6. Restore Default Behavior

After debugging, delete or clear `debug.toml` to restore fetching data from the network:

```toml
[install]
online-distros = ''

[distro]
cleanup-script = ''
```

Or simply delete the entire file.

---

## Submission Process

1. **Fork** this repository to your GitHub account
2. **Clone** locally:
   ```bash
   git clone https://github.com/<your username>/wsl-community.git
   ```
3. **Create branch**:
   ```bash
   git checkout -b feat/add-new-distro
   ```
4. **Edit files**: Modify data or scripts under `www/` directory
5. **Local debug**: Verify changes following the "Local Debugging" steps above
6. **Commit and push**:
   ```bash
   git add www/api/install/online-distros
   git commit -m "feat: add Ubuntu 24.10 mirror source"
   git push origin feat/add-new-distro
   ```
7. **Create Pull Request**: Target branch is `main`
8. **Auto-deploy after merge**: After PR is merged to `main`, changes will be automatically published to `https://api3.wslui.com`

---

## Notes

- **Do not commit sensitive information**: This repository is public, all content is visible to everyone
- **JSON format validation**: After modifying `online-distros`, use a JSON validation tool to check the format
- **Keep JSON formatted**: JSON files must use indented formatting (4-space indent), **do not use minified/compressed JSON**. This allows git diff to clearly show line-level changes for code review
- **Consistent indentation**: All files use **4 spaces** for indentation, tabs are prohibited (the project has `.editorconfig` configured, mainstream editors will follow automatically)
- **Script compatibility**: Cleanup scripts should be compatible with mainstream Linux distros
- **No file extension in URL**: Access via `/api/install/online-distros`, not `.json`
- **Distro sorting rule**: The `data.distros` array in the `online-distros` file must be sorted by:
  - Primary key: `name` (distribution name), **descending** (Z → A)
  - Secondary key: `version` (version number), **descending** (higher versions first)
  - Example order: `Ubuntu 24.04` → `Ubuntu 22.04` → `Ubuntu 20.04` → ... → `Amazon Linux 2023` → `Amazon Linux 2` → `AlmaLinux 10` → `Alpine 3.24` → `Alpine 3.22`
  - This allows contributors to quickly determine where to insert new distributions, keeping the file structure clear and facilitating code review
- **Mirror source sorting rule**: The `sources` array within each distro (`data.distros[*].sources[*]`) must be sorted by the `mirror` field **descending** (Z → A), so contributors can quickly determine where to insert new mirror sources

---

## License

Licensed under the [GPLv3 License](LICENSE).



