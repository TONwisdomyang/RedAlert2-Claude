#!/bin/bash

# Red Alert 2 Sound System for Claude Code - Installer
# Minimal installation script

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
echo -e "${BLUE}================================${NC}"
echo ""

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo -e "${YELLOW}⚠ fswatch is not installed${NC}"
    echo -e "Please install it first:"
    echo -e "  ${BLUE}brew install fswatch${NC}"
    echo ""
    read -p "Press Enter to continue after installing fswatch, or Ctrl+C to exit..."
fi

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$TARGET_DIR/done"
mkdir -p "$TARGET_DIR/start"
mkdir -p "$TARGET_DIR/userpromptsubmit"
mkdir -p "$TARGET_DIR/precompact"
echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Copy audio files
echo -e "${YELLOW}Copying audio files...${NC}"
cp "$SCRIPT_DIR/sounds/uplace.wav" "$TARGET_DIR/done/"
cp "$SCRIPT_DIR/sounds/igidepa.wav" "$TARGET_DIR/start/"
cp "$SCRIPT_DIR/sounds/vpriata.wav" "$TARGET_DIR/userpromptsubmit/"
cp "$SCRIPT_DIR/sounds/snukread.wav" "$TARGET_DIR/precompact/"
echo -e "${GREEN}✓ Audio files copied${NC}"
echo ""

# Copy zsh script
echo -e "${YELLOW}Installing sound watcher script...${NC}"
cp "$SCRIPT_DIR/ra2-claude-sounds.zsh" "$HOME/.ra2-claude-sounds.zsh"
echo -e "${GREEN}✓ Script installed to ~/.ra2-claude-sounds.zsh${NC}"
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

# Add to zshrc
echo -e "${YELLOW}Updating ~/.zshrc...${NC}"
if grep -q "ra2-claude-sounds.zsh" ~/.zshrc 2>/dev/null; then
    echo -e "${YELLOW}✓ Already in ~/.zshrc${NC}"
else
    echo "" >> ~/.zshrc
    echo "# Red Alert 2 Sound System for Claude Code" >> ~/.zshrc
    echo "source ~/.ra2-claude-sounds.zsh" >> ~/.zshrc
    echo -e "${GREEN}✓ Added to ~/.zshrc${NC}"
fi
echo ""

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Reload your shell:"
echo -e "   ${YELLOW}source ~/.zshrc${NC}"
echo ""
echo -e "2. The sound watcher will start automatically"
echo -e "   Check status: ${YELLOW}claude_sound_watcher_status${NC}"
echo ""
echo -e "3. Toggle sounds on/off anytime:"
echo -e "   ${YELLOW}cst${NC}"
echo ""
echo -e "${BLUE}Enjoy your Red Alert 2 enhanced Claude Code!${NC}"
echo -e "${BLUE}Kirov reporting! 🎮🔊${NC}"
echo ""
