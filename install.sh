#!/usr/bin/env bash
# ccstatusline installer
# Usage: curl -fsSL https://raw.githubusercontent.com/bradsec/ccstatusline/main/install.sh | bash

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/bradsec/ccstatusline/main"
HOOK_DEST="$HOME/.claude/hooks/statusline-enhanced.js"
SETTINGS="$HOME/.claude/settings.json"

echo "ccstatusline installer"
echo "----------------------"

# Create hooks directory
mkdir -p "$HOME/.claude/hooks"

# Download the statusline script
if command -v curl &>/dev/null; then
  curl -fsSL "$REPO_RAW/hooks/statusline-enhanced.js" -o "$HOOK_DEST"
elif command -v wget &>/dev/null; then
  wget -qO "$HOOK_DEST" "$REPO_RAW/hooks/statusline-enhanced.js"
else
  echo "Error: neither curl nor wget found. Please install one and retry." >&2
  exit 1
fi

chmod +x "$HOOK_DEST"
echo "Installed: $HOOK_DEST"

# Auto-update settings.json
STATUSLINE_CMD="node \"$HOOK_DEST\""

if ! command -v node &>/dev/null; then
  echo ""
  echo "Warning: node not found — skipping settings.json update."
  echo "Install Node.js, then add the following to $SETTINGS:"
  echo ""
  echo "  {"
  echo "    \"statusLine\": {"
  echo "      \"type\": \"command\","
  echo "      \"command\": \"$STATUSLINE_CMD\""
  echo "    }"
  echo "  }"
else
  mkdir -p "$(dirname "$SETTINGS")"
  SETTINGS="$SETTINGS" STATUSLINE_CMD="$STATUSLINE_CMD" node -e "
    const fs = require('fs');
    const settingsPath = process.env.SETTINGS;
    const cmd = process.env.STATUSLINE_CMD;
    let config = {};
    if (fs.existsSync(settingsPath)) {
      try { config = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch(e) {}
    }
    config.statusLine = { type: 'command', command: cmd };
    fs.writeFileSync(settingsPath, JSON.stringify(config, null, 2) + '\n');
  "
  echo "Updated: $SETTINGS"
fi

echo ""
echo "Restart Claude Code to activate the statusline."
