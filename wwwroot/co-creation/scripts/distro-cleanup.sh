#!/bin/bash
# Auto-detect available package managers via command -v

# Clean system temporary files (common to all distros)
sudo rm -rf /tmp/* 2>/dev/null || true
sudo rm -rf /var/tmp/* 2>/dev/null || true

# Package manager cache cleanup (auto-detect)
if command -v apt-get &>/dev/null; then
    sudo apt-get clean -y      # Debian/Ubuntu
fi
if command -v dnf &>/dev/null; then
    sudo dnf clean all -y     # Fedora/RHEL
fi
if command -v pacman &>/dev/null; then
    sudo pacman -Sc --noconfirm  # Arch Linux
fi
if command -v zypper &>/dev/null; then
    sudo zypper clean -a      # openSUSE
fi
if command -v apk &>/dev/null; then
    sudo apk cache clean      # Alpine
fi

# User cache cleanup (common to all distros)
rm -rf ~/.cache/* 2>/dev/null || true
rm -rf ~/.local/share/Trash/* 2>/dev/null || true

# Write completion timestamp to log
echo "$(date '+%Y-%m-%d %H:%M:%S') cleanup completed" >> /home/wsl-dashboard-cleanup.log
