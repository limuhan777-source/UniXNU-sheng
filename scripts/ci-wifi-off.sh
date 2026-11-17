#!/usr/bin/env bash
# Skip the Wi-Fi userspace build: the WCN7850 supplicant sources are not in this
# repository, so build-wifi-userspace.py always fails. The key in board.toml is a
# bare TOML key (no quotes), so comment it out before unixnu reads the board.
set -euo pipefail

if [ -f board.toml ]; then
  perl -pi -e 's|^wifi_tool|# wifi_tool|' board.toml || true
  grep -n 'wifi_tool' board.toml || true
fi
