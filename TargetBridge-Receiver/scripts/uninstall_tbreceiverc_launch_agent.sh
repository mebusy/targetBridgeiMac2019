#!/bin/zsh
set -euo pipefail

PLIST_PATH="${HOME}/Library/LaunchAgents/com.targetbridge.receiver.plist"

launchctl bootout "gui/$(id -u)" "${PLIST_PATH}" >/dev/null 2>&1 || true
rm -f "${PLIST_PATH}"

echo "LaunchAgent removed: ${PLIST_PATH}"
echo "TargetBridge Receiver will no longer start automatically at login."
