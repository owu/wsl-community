# Debug Mode

This document describes the WSL Dashboard debug configuration file `debug.toml`, which is used to load local files during development and testing, bypassing network requests.

## Configuration File Location

```
~/.wsldashboard/debug.toml
```

On Windows, this is typically: `C:\Users\<username>\.wsldashboard\debug.toml`

This file is optional. If the file does not exist, the software will use default behavior (fetching data from the network) and will not produce errors.

---

## Configuration Options

### `[install]` - Installation Debug

| Option | Type | Description |
|--------|------|-------------|
| `online-distros` | `string` | Absolute path to a local mirror list JSON file. When set, online distro installation will read data from this local file instead of fetching from the network. |

**Scope:** When creating a new instance and selecting "Online Distro (Mirror)" as the source, it loads the installable distro list.

**Behavior:**
1. Check if `online-distros` is empty
2. If not empty → load `MirrorListResponse` data from the local JSON file
3. If empty → fetch mirror list from the network API as usual

### `[distro]` - Distro Operations Debug

| Option | Type | Description |
|--------|------|-------------|
| `cleanup-script` | `string` | Absolute path to a local cleanup script (`.sh` file). When set, the cleanup phase during compression will execute this local script instead of downloading the default cleanup script from the network. |

**Scope:** Used during the cleanup phase when compressing VHDX disks.

**Behavior:**
1. Check if `cleanup-script` is empty
2. If not empty → verify the file exists and is a `.sh` file, then execute the script within the WSL distro
3. If empty → download the default cleanup script from the network and execute it

---

## Configuration File Example

```toml
[install]
online-distros = 'D:\develop\wsl-community\www\api\install\online-distros'

[distro]
cleanup-script = 'D:\develop\wsl-community\www\scripts\home\distro-cleanup.sh'
```

---

## Local Mirror JSON File Format

The JSON file pointed to by `online-distros` must conform to the `ApiResponse<MirrorListResponse>` structure:

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

**Field Descriptions:**
- `err`: Error code, `0` on success
- `msg`: Message text
- `data.update_time`: Data update time
- `data.version`: Data version
- `data.distros`: Distro list
    - `name`: Distro name
    - `version`: Version number
    - `arch`: Architecture (e.g., `x64`, `arm64`)
    - `sources`: Download source list
        - `url`: Download URL
        - `mirror`: Mirror site name
        - `format`: File format (e.g., `tar.gz`, `wsl`)
        - `file_size`: File size in bytes (optional)
        - `last_modified`: Last modified time (optional)

---

## Local Cleanup Script Requirements

The script file pointed to by `cleanup-script` must meet the following conditions:

1. The file must exist
2. The file extension must be `.sh`
3. The script will be executed as `root` within the WSL distro
4. The script content should be a valid Shell script for cleaning temporary files and package caches

---

## Key Log Output

The software outputs the following logs when processing debug configuration, viewable via log files or console:

### Configuration Loading Phase

| Level | Log Message | Description |
|-------|-------------|-------------|
| `INFO` | `[DebugConfig] debug.toml not found at <path>, using defaults` | Config file not found, using defaults |
| `INFO` | `[DebugConfig] Loaded debug.toml from <path>: install.online-distros='<value>'` | Config file loaded successfully |
| `WARN` | `[DebugConfig] Failed to parse debug.toml at <path>: <error>. Using defaults.` | Config file parse failed |
| `WARN` | `[DebugConfig] Failed to read debug.toml at <path>: <error>. Using defaults.` | Config file read failed |

### Online Distro Loading Phase (`online-distros`)

| Level | Log Message | Description |
|-------|-------------|-------------|
| `INFO` | `[Debug] install.online-distros is set to '<path>', using local file instead of network` | Using local file to load mirror list |
| `INFO` | `[Debug] install.online-distros is empty, fetching mirror distros from network` | Config is empty, fetching from network |
| `INFO` | `[Debug] Parsed MirrorListResponse from local file: <N> distros` | Local file parsed successfully, contains N distros |
| `WARN` | `[Debug] Local mirror JSON file not found: <path>` | Local JSON file not found |
| `WARN` | `[Debug] Failed to parse MirrorListResponse from '<path>': <error>` | Local JSON file parse failed |
| `WARN` | `[Debug] Failed to read local mirror JSON '<path>': <error>` | Local JSON file read failed |

### Cleanup Script Phase (`cleanup-script`)

| Level | Log Message | Description |
|-------|-------------|-------------|
| `INFO` | `[Debug] distro.cleanup-script is set to '<path>', skipping wslui_helper_distro() API call` | Using local cleanup script, skipping network API call |
| `INFO` | `Executing local cleanup script from: <path>` | Starting to execute local cleanup script |
| `WARN` | `Local cleanup script failed: <error>` | Local cleanup script execution failed |

### User Interface Messages (i18n Keys)

When debug configuration issues occur, the software displays the following messages in the UI:

| i18n Key | English |
|----------|---------|
| `debug.mirrors_file_not_found` | [Debug] The specified local mirror JSON file does not exist. |
| `debug.mirrors_parse_failed` | [Debug] Could not parse the local mirror JSON file. |
| `debug.cleanup_script_invalid` | [Debug] The specified local cleanup script is missing or not a .sh file. |

---

## Usage Scenarios

### Scenario 1: Testing Online Distro Installation

1. Prepare a local JSON file that meets the format requirements (see format above)
2. Configure `online-distros` in `debug.toml` to point to that file
3. Launch the software, go to "Create New Instance" → select "Online Distro (Mirror)"
4. The software will load the distro list from the local file instead of fetching from the network

### Scenario 2: Testing Compression Cleanup Script

1. Prepare a local `.sh` cleanup script
2. Configure `cleanup-script` in `debug.toml` to point to that script
3. Execute compression on any installed distro
4. The software will execute the local script during the cleanup phase instead of downloading from the network

---

## Related Source Files

| File Path | Description |
|-----------|-------------|
| `src/config/debug.rs` | Debug config struct definition and loading logic |
| `src/app/state.rs` | Application state holding `debug_config` field |
| `src/ui/handlers/distro/install.rs` | Reading `online-distros` config during installation |
| `src/ui/handlers/distro/compress.rs` | Reading `cleanup-script` config during compression |
| `src/ui/data.rs` | `load_local_mirror_distros()` function, local mirror loading implementation |
| `src/wsl/ops/compress.rs` | `cleanup_temp_files()` function, cleanup script execution logic |
