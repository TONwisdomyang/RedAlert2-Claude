# 🎮 Red Alert 2 Sound System for Claude Code

Add immersive Red Alert 2 sound effects to your Claude Code experience! Hear authentic game sounds when Claude completes tasks, starts sessions, and more.

## 🎵 Sound Effects

This system uses 5 carefully selected Red Alert 2 sounds:

| Event | Sound | Description |
|-------|-------|-------------|
| **Task Complete** | Mission Complete | Red Alert 2 mission complete sound |
| **Session Start** | GI "Yes, Sir!" | American GI saying "是，长官！" when you start Claude |
| **Prompt Submit** | Prism Tank Attack | **"Calculating Reflection Arcs!"** - Prism Tank attack command |
| **Context Compact** | Nuclear Warning | EVA nuclear silo warning alert |
| **Approval Needed** | Kirov Reporting | **"基洛夫报到"** - Kirov airship when Claude needs your approval |

## 📋 Prerequisites

- **macOS** (uses `afplay` for audio playback)
- **[fswatch](https://github.com/emcrisostomo/fswatch)** for file monitoring
- **Claude Code CLI** installed
- **zsh** shell (default on macOS)

## 🚀 Installation

### Quick Install (Recommended)

```bash
# 1. Install fswatch
brew install fswatch

# 2. Clone and run installer
git clone https://github.com/op7418/RedAlert2-Claude.git
cd RedAlert2-Claude
./install.sh

# 3. Reload your shell
source ~/.zshrc
```

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

1. **Install fswatch**
   ```bash
   brew install fswatch
   ```

2. **Create directories**
   ```bash
   mkdir -p ~/.claude/sounds/{done,start,userpromptsubmit,precompact,approval}
   ```

3. **Copy audio files**
   ```bash
   cp sounds/task-complete.wav ~/.claude/sounds/done/
   cp sounds/session-start.wav ~/.claude/sounds/start/
   cp sounds/vpriata.wav ~/.claude/sounds/userpromptsubmit/
   cp sounds/context-compact.wav ~/.claude/sounds/precompact/
   cp sounds/approval-needed.wav ~/.claude/sounds/approval/
   ```

4. **Install the sound watcher script**
   ```bash
   cp ra2-claude-sounds.zsh ~/.ra2-claude-sounds.zsh
   ```

5. **Add to your ~/.zshrc**
   ```bash
   echo 'source ~/.ra2-claude-sounds.zsh' >> ~/.zshrc
   source ~/.zshrc
   ```

6. **Configure Claude Code hooks**

   Edit `~/.claude/settings.json` and add:
   ```json
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
   ```

</details>

## 🎮 Usage

### Toggle Sounds On/Off

```bash
cst  # Quick toggle
```

Or use the full command:
```bash
claude_sounds_toggle
```

### Check Status

```bash
claude_sound_watcher_status
```

### Manual Control

```bash
claude_sound_watcher_start     # Start the sound watcher
claude_sound_watcher_stop      # Stop the sound watcher
claude_sound_watcher_restart   # Restart the sound watcher
```

### Test Sounds

```bash
# Test each sound manually
touch ~/.claude/.claude-done      # Task complete sound
touch ~/.claude/.claude-start     # Session start sound
touch ~/.claude/.claude-prompt    # Prompt submit sound (Prism Tank!)
touch ~/.claude/.claude-compact   # Context compact sound (Nuclear warning!)
touch ~/.claude/.claude-approval  # Approval needed sound (Kirov reporting!)
```

**Note**: The approval sound is ready but currently needs to be triggered manually. Claude Code may add approval hooks in future versions.

## 🔧 Customization

### Adjust Volume

Set the volume (0.0 to 1.0) in your `~/.zshrc` before sourcing the script:

```bash
export CLAUDE_SOUND_VOLUME=0.5  # 50% volume (default is 0.3)
source ~/.ra2-claude-sounds.zsh
```

Then restart the watcher:
```bash
claude_sound_watcher_restart
```

### Add More Sounds

Want variety? Just add more `.wav` files to any sound directory:

```bash
# Example: Add more sounds to the "done" event
cp your-sound.wav ~/.claude/sounds/done/

# The system will randomly pick one from the directory
```

### Change Sound Directories

You can override the default sound directory:

```bash
export CLAUDE_SOUNDS_DIR="$HOME/custom/sounds"
source ~/.ra2-claude-sounds.zsh
```

## 🛠️ Troubleshooting

### No sounds playing?

1. **Check if fswatch is installed**
   ```bash
   fswatch --version
   ```

2. **Check if the watcher is running**
   ```bash
   claude_sound_watcher_status
   ```

3. **Verify audio files exist**
   ```bash
   ls -R ~/.claude/sounds/
   ```

4. **Check Claude Code hooks**
   ```bash
   cat ~/.claude/settings.json | grep -A 5 hooks
   ```

### Sounds too loud/quiet?

```bash
export CLAUDE_SOUND_VOLUME=0.2  # Try 20%
claude_sound_watcher_restart
```

### Want to disable temporarily?

```bash
cst  # Toggle off
```

Run again to re-enable.

## 🎯 How It Works

1. **Claude Code Hooks**: When events occur (task complete, prompt submit, etc.), Claude Code triggers hooks that create temporary files
2. **File Watchers**: The zsh script uses `fswatch` to monitor these trigger files
3. **Sound Playback**: When a trigger file is created, a sound from the corresponding directory is played using `afplay`, then the trigger file is deleted
4. **Background Process**: All watchers run as a single background process

## 📝 Files Included

```
ra2-claude-sounds/
├── sounds/                      # Audio files
│   ├── task-complete.wav        # Mission complete (task complete)
│   ├── session-start.wav        # GI "Yes, Sir!" (session start)
│   ├── vpriata.wav              # Prism Tank attack (prompt submit)
│   ├── context-compact.wav      # Nuclear warning (context compact)
│   └── approval-needed.wav      # Kirov reporting (approval needed)
├── ra2-claude-sounds.zsh        # Main sound watcher script
├── install.sh                   # Installation script
├── HOOKS.json                   # Claude Code hooks configuration
├── README.md                    # This file
└── CLAUDE_PROMPT.md             # Instructions for AI assistants
```

## 🤖 For AI Assistants

If you're Claude (or another AI) helping a user with this project, see [CLAUDE_PROMPT.md](CLAUDE_PROMPT.md) for specific instructions on how to work with this sound system.

## 📜 License

This project is for personal use only. Red Alert 2 audio files are property of Electronic Arts Inc. and Westwood Studios.

**Audio Files**: The included `.wav` files are from Command & Conquer: Red Alert 2, © EA / Westwood Studios. All rights reserved. These files are included under fair use for personal, non-commercial purposes only.

**Code**: MIT License - feel free to use, modify, and distribute the scripts.

## 🙏 Credits

- **Game**: Command & Conquer: Red Alert 2 by Westwood Studios / EA
- **Inspired by**: StarCraft Claude Sounds projects
- **Audio**: All sounds are from Red Alert 2

## 🎮 Enjoy!

**Kirov reporting!** 🎮🔊

Now enjoy your enhanced Claude Code experience with authentic Red Alert 2 sounds!

---

**Questions or Issues?** Open an issue on GitHub or check the troubleshooting section above.
