# 🎮 Red Alert 2 Sound System for Claude Code - Windows Edition

Add immersive Red Alert 2 sound effects to your Claude Code experience on Windows! Hear authentic game sounds when Claude completes tasks, starts sessions, and more.

> **Windows Port**: This is a fully-featured Windows adaptation of the [original macOS version](https://github.com/op7418/RedAlert2-Claude), using Git Bash + PowerShell instead of zsh + afplay + fswatch.

## 🎵 Sound Effects

| Event | Sound | Description |
|-------|-------|-------------|
| **Task Complete** | Mission Complete | Red Alert 2 mission complete sound |
| **Session Start** | GI "Yes, Sir!" | American GI saying "是，长官！" when you start Claude |
| **Prompt Submit** | Prism Tank Attack | **"Calculating Reflection Arcs!"** - Prism Tank attack command |
| **Context Compact** | Nuclear Warning | EVA nuclear silo warning alert |
| **Approval Needed** | Kirov Reporting | **"基洛夫报到"** - Kirov airship when Claude needs your approval |

## 📋 Prerequisites

- **Windows 10/11** with Git Bash (comes with [Git for Windows](https://git-scm.com/download/win))
- **Claude Code CLI** installed
- **PowerShell** (pre-installed on Windows)

### Optional

- **WSL (Windows Subsystem for Linux)** - also supported!

## 🚀 Installation

### Automatic Installation (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/op7418/RedAlert2-Claude.git
cd RedAlert2-Claude

# 2. Run the Windows installer
./install-windows.sh

# 3. Restart your Git Bash terminal
# The sound system will start automatically
```

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

1. **Create directories**
   ```bash
   mkdir -p ~/.claude/sounds/{done,start,userpromptsubmit,precompact,approval}
   ```

2. **Copy audio files**
   ```bash
   cp sounds/task-complete.wav ~/.claude/sounds/done/
   cp sounds/session-start.wav ~/.claude/sounds/start/
   cp sounds/vpriata.wav ~/.claude/sounds/userpromptsubmit/
   cp sounds/context-compact.wav ~/.claude/sounds/precompact/
   cp sounds/approval-needed.wav ~/.claude/sounds/approval/
   ```

3. **Install the sound watcher script**
   ```bash
   cp ra2-claude-sounds-windows.sh ~/.claude/ra2-claude-sounds-windows.sh
   ```

4. **Add to your ~/.bashrc**
   ```bash
   echo 'source ~/.claude/ra2-claude-sounds-windows.sh' >> ~/.bashrc
   source ~/.bashrc
   ```

5. **Configure Claude Code hooks**

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
claude_sounds_toggle  # or: cst (short alias)
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

### Help

```bash
claude_sound_help  # Show complete help
```

## 🔧 Customization

### Add More Sounds

Want variety? Just add more `.wav`, `.mp3`, or `.m4a` files to any sound directory:

```bash
# Example: Add more sounds to the "done" event
cp your-sound.wav ~/.claude/sounds/done/

# The system will randomly pick one from the directory
```

### Change Sound Directories

You can override the default sound directory:

```bash
export CLAUDE_SOUNDS_DIR="$HOME/custom/sounds"
source ~/.claude/ra2-claude-sounds-windows.sh
```

## 🛠️ Troubleshooting

### No sounds playing?

1. **Check if the watcher is running**
   ```bash
   claude_sound_watcher_status
   ```

2. **Verify audio files exist**
   ```bash
   ls -R ~/.claude/sounds/
   ```

3. **Check Claude Code hooks**
   ```bash
   cat ~/.claude/settings.json | grep -A 5 hooks
   ```

4. **Test PowerShell audio playback**
   ```bash
   powershell.exe -Command "(New-Object System.Media.SoundPlayer ~/.claude/sounds/done/task-complete.wav).PlaySync()"
   ```

5. **Restart the watcher**
   ```bash
   claude_sound_watcher_restart
   ```

### Want to disable temporarily?

```bash
claude_sounds_toggle  # Toggle off
# ... work quietly ...
claude_sounds_toggle  # Toggle back on
```

### WSL Users

If using WSL, the script will automatically detect and use `wslpath` instead of `cygpath` for path conversion.

## 🎯 How It Works

1. **Claude Code Hooks**: When events occur (task complete, prompt submit, etc.), Claude Code triggers hooks that create temporary files
2. **File Watchers**: The bash script polls these trigger files every 300ms
3. **Sound Playback**: When a trigger file is detected, a random sound from the corresponding directory is played using PowerShell's `System.Media.SoundPlayer`, then the trigger file is deleted
4. **Background Process**: All watchers run as a single background process with PID tracking

## 🆚 Differences from macOS Version

| Feature | macOS Version | Windows Version |
|---------|---------------|-----------------|
| File Monitoring | `fswatch` (event-driven) | Polling loop (300ms interval) |
| Audio Playback | `afplay` | PowerShell `SoundPlayer` |
| Shell | zsh | bash (Git Bash) |
| Volume Control | 0.0-1.0 scale | Reserved for future (Windows API) |
| Path Conversion | Native | `cygpath` / `wslpath` |
| Process Management | `pkill -P` | `taskkill //T` (Windows) |

### Windows-Specific Enhancements

- ✨ **Debouncing**: Prevents sound overlap from rapid triggers (1-second cooldown)
- 🔒 **Security**: Escapes PowerShell injection vulnerabilities
- 🎯 **File Validation**: Checks file size (1KB-10MB) before playback
- 🔄 **WSL Support**: Auto-detects and supports both Git Bash and WSL
- 💻 **Better Process Cleanup**: Uses Windows `taskkill` for complete process tree termination

## 📝 Files Included

```
RedAlert2-Claude/
├── sounds/                          # Audio files (same as macOS)
│   ├── task-complete.wav
│   ├── session-start.wav
│   ├── vpriata.wav
│   ├── context-compact.wav
│   └── approval-needed.wav
├── ra2-claude-sounds-windows.sh     # Windows bash script
├── install-windows.sh               # Windows installation script
├── README_WINDOWS.md                # This file
└── README.md                        # Original macOS README
```

## 📊 Performance

- **CPU Usage**: ~0.1% (5 watchers × 300ms polling)
- **Memory**: ~5MB (bash + watchers)
- **Battery Impact**: Minimal (efficient polling)

## 🧪 Tested On

- ✅ Windows 11 + Git Bash (MSYS2)
- ✅ Windows 10 + Git Bash
- ✅ WSL2 (Ubuntu 22.04)

## 🙏 Credits

- **Game**: Command & Conquer: Red Alert 2 by Westwood Studios / EA
- **Original Project**: [RedAlert2-Claude](https://github.com/op7418/RedAlert2-Claude) by [@op7418](https://github.com/op7418)
- **Windows Port**: Developed with assistance from Claude Code
- **Audio**: All sounds are from Red Alert 2

## 📜 License

**Audio Files**: The included `.wav` files are from Command & Conquer: Red Alert 2, © EA / Westwood Studios. All rights reserved. These files are included under fair use for personal, non-commercial purposes only.

**Code**: MIT License - feel free to use, modify, and distribute the scripts.

## 🎮 Enjoy!

**Kirov reporting!** 🎮🔊

Now enjoy your enhanced Claude Code experience with authentic Red Alert 2 sounds on Windows!

---

**Questions or Issues?** Open an issue on [GitHub](https://github.com/op7418/RedAlert2-Claude/issues)
