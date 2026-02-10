#!/bin/bash

# Red Alert 2 Sound System for Claude Code - Windows Installer
# Installs the Windows version using Git Bash + PowerShell

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/sounds"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Red Alert 2 Sounds for Claude${NC}"
echo -e "${BLUE}    (Windows Edition)${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check environment
echo -e "${YELLOW}Checking environment...${NC}"

# Check if running on Windows
if [[ ! "$OSTYPE" =~ ^(msys|cygwin|win32) ]] && [[ ! "$(uname -r)" =~ Microsoft|WSL ]]; then
    echo -e "${RED}⚠ This installer is for Windows (Git Bash or WSL)${NC}"
    echo -e "For macOS, use: ./install.sh"
    exit 1
fi

# Check PowerShell
if ! command -v powershell.exe &> /dev/null; then
    echo -e "${RED}⚠ PowerShell not found${NC}"
    echo -e "PowerShell is required for audio playback on Windows."
    exit 1
fi

echo -e "${GREEN}✓ Windows environment detected${NC}"
echo -e "${GREEN}✓ PowerShell available${NC}"
echo ""

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$TARGET_DIR/done"
mkdir -p "$TARGET_DIR/start"
mkdir -p "$TARGET_DIR/userpromptsubmit"
mkdir -p "$TARGET_DIR/precompact"
mkdir -p "$TARGET_DIR/approval"
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Copy audio files
echo -e "${YELLOW}Copying audio files...${NC}"
cp "$SCRIPT_DIR/sounds/task-complete.wav" "$TARGET_DIR/done/"
cp "$SCRIPT_DIR/sounds/session-start.wav" "$TARGET_DIR/start/"
cp "$SCRIPT_DIR/sounds/vpriata.wav" "$TARGET_DIR/userpromptsubmit/"
cp "$SCRIPT_DIR/sounds/context-compact.wav" "$TARGET_DIR/precompact/"
cp "$SCRIPT_DIR/sounds/approval-needed.wav" "$TARGET_DIR/approval/"
echo -e "${GREEN}✓ Audio files copied${NC}"
echo ""

# Copy Windows script
echo -e "${YELLOW}Installing sound watcher script...${NC}"
cp "$SCRIPT_DIR/ra2-claude-sounds-windows.sh" "$HOME/.claude/ra2-claude-sounds-windows.sh"
echo -e "${GREEN}✓ Script installed to ~/.claude/ra2-claude-sounds-windows.sh${NC}"
echo ""

# Check and update settings.json
echo -e "${YELLOW}Checking Claude Code settings...${NC}"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}Creating new settings.json${NC}"
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear",
        "hooks": [
          {
            "type": "command",
            "command": "touch ~/.claude/.claude-start"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "touch ~/.claude/.claude-prompt"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "touch ~/.claude/.claude-done"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "touch ~/.claude/.claude-compact"
          }
        ]
      }
    ]
  }
}
EOF
    echo -e "${GREEN}✓ settings.json created${NC}"
else
    echo -e "${YELLOW}⚠ settings.json already exists${NC}"
    echo -e "Please add the following hooks configuration manually:"
    echo -e "${BLUE}See HOOKS.json for the required configuration${NC}"
fi
echo ""

# Add to shell config
SHELL_CONFIG=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
else
    SHELL_CONFIG="$HOME/.bashrc"
    touch "$SHELL_CONFIG"
fi

echo -e "${YELLOW}Updating $SHELL_CONFIG...${NC}"
if grep -q "ra2-claude-sounds-windows.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}✓ Already in $SHELL_CONFIG${NC}"
else
    echo "" >> "$SHELL_CONFIG"
    echo "# Red Alert 2 Sound System for Claude Code (Windows)" >> "$SHELL_CONFIG"
    echo "source ~/.claude/ra2-claude-sounds-windows.sh" >> "$SHELL_CONFIG"
    echo -e "${GREEN}✓ Added to $SHELL_CONFIG${NC}"
fi
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Restart your terminal (Git Bash) or run:"
echo -e "   ${YELLOW}source $SHELL_CONFIG${NC}"
echo ""
echo -e "2. The sound watcher will start automatically"
echo -e "   Check status: ${YELLOW}claude_sound_watcher_status${NC}"
echo ""
echo -e "3. Toggle sounds on/off anytime:"
echo -e "   ${YELLOW}claude_sounds_toggle${NC} (or just: ${YELLOW}cst${NC})"
echo ""
echo -e "4. Test sounds manually:"
echo -e "   ${YELLOW}touch ~/.claude/.claude-done${NC}"
echo ""
echo -e "5. Get help:"
echo -e "   ${YELLOW}claude_sound_help${NC}"
echo ""
echo -e "${BLUE}Enjoy your Red Alert 2 enhanced Claude Code!${NC}"
echo -e "${BLUE}Kirov reporting! 🎮🔊${NC}"
echo ""
