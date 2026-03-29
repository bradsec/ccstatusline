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

# Print the settings.json snippet
echo ""
echo "Add the following to $SETTINGS"
echo "(merge into the existing JSON object if the file already exists):"
echo ""
echo "  {"
echo "    \"statusLine\": {"
echo "      \"type\": \"command\","
echo "      \"command\": \"node \\\"$HOOK_DEST\\\"\""
echo "    }"
echo "  }"
echo ""
echo "Then restart Claude Code to activate the statusline."
