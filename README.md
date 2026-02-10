# 🎮 Red Alert 2 Sound System for Claude Code

Add immersive Red Alert 2 sound effects to your Claude Code experience! Hear authentic game sounds when Claude completes tasks, starts sessions, and more.

> **Multi-Platform Support**: Now available for both **macOS** and **Windows** (Git Bash / WSL)!

## 🎵 Sound Effects

This system uses 5 carefully selected Red Alert 2 sounds:

| Event | Sound | Description |
|-------|-------|-------------|
| **Task Complete** | Mission Complete | Red Alert 2 mission complete sound |
| **Session Start** | GI "Yes, Sir!" | American GI saying "是，长官！" when you start Claude |
| **Prompt Submit** | Prism Tank Attack | **"Calculating Reflection Arcs!"** - Prism Tank attack command |
| **Context Compact** | Nuclear Warning | EVA nuclear silo warning alert |
| **Approval Needed** | Kirov Reporting | **"基洛夫报到"** - Kirov airship when Claude needs your approval |

## 📋 Platform Support

### macOS
- **Audio**: `afplay` (built-in)
- **File Monitoring**: `fswatch` (install via brew)
- **Shell**: zsh (default)

### Windows
- **Audio**: PowerShell `System.Media.SoundPlayer` (built-in)
- **File Monitoring**: Polling (no dependencies)
- **Shell**: bash (Git Bash or WSL)

## 🚀 Installation

### Choose Your Platform

<details open>
<summary><b>macOS Installation</b></summary>

#### Quick Install (Recommended)

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

#### Manual Installation

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

   Edit `~/.claude/settings.json` and add the hooks from `HOOKS.json`

</details>

<details>
<summary><b>Windows Installation (Git Bash / WSL)</b></summary>

#### Quick Install (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/op7418/RedAlert2-Claude.git
cd RedAlert2-Claude

# 2. Run the Windows installer
./install-windows.sh

# 3. Restart your Git Bash terminal
# The sound system will start automatically
```

#### Manual Installation

See [README_WINDOWS.md](README_WINDOWS.md) for detailed Windows installation instructions.

</details>

## 🎮 Usage

### Toggle Sounds On/Off

**macOS:**
```bash
cst  # Quick toggle
```

**Windows:**
```bash
claude_sounds_toggle  # or: cst
```

### Check Status

**macOS:**
```bash
claude_sound_watcher_status
```

**Windows:**
```bash
claude_sound_watcher_status
```

### Manual Control

**macOS:**
```bash
claude_sound_watcher_start     # Start the sound watcher
claude_sound_watcher_stop      # Stop the sound watcher
claude_sound_watcher_restart   # Restart the sound watcher
```

**Windows:**
```bash
claude_sound_watcher_start     # Start the sound watcher
claude_sound_watcher_stop      # Stop the sound watcher
claude_sound_watcher_restart   # Restart the sound watcher
```

### Test Sounds

```bash
# Test each sound manually (works on both platforms)
touch ~/.claude/.claude-done      # Task complete sound
touch ~/.claude/.claude-start     # Session start sound
touch ~/.claude/.claude-prompt    # Prompt submit sound (Prism Tank!)
touch ~/.claude/.claude-compact   # Context compact sound (Nuclear warning!)
touch ~/.claude/.claude-approval  # Approval needed sound (Kirov reporting!)
```

## 🔧 Customization

### Add More Sounds

Want variety? Just add more `.wav` files to any sound directory:

```bash
# Example: Add more sounds to the "done" event
cp your-sound.wav ~/.claude/sounds/done/

# The system will randomly pick one from the directory
```

### Adjust Volume

**macOS:**
```bash
export CLAUDE_SOUND_VOLUME=0.5  # 50% volume (default is 0.3)
source ~/.ra2-claude-sounds.zsh
claude_sound_watcher_restart
```

**Windows:**
Volume control is handled by Windows system volume (PowerShell limitation).

## 🛠️ Troubleshooting

### macOS

1. **No sounds playing?**
   - Check if fswatch is installed: `fswatch --version`
   - Check if watcher is running: `claude_sound_watcher_status`
   - Verify audio files exist: `ls -R ~/.claude/sounds/`

2. **Sounds too loud/quiet?**
   ```bash
   export CLAUDE_SOUND_VOLUME=0.2  # Try 20%
   claude_sound_watcher_restart
   ```

### Windows

1. **No sounds playing?**
   - Check if watcher is running: `claude_sound_watcher_status`
   - Verify audio files exist: `ls -R ~/.claude/sounds/`
   - Test PowerShell: `powershell.exe -Command "echo test"`

2. **Sounds overlapping (echo effect)?**
   - Check for multiple watcher processes: `ps aux | grep claude`
   - Restart watcher: `claude_sound_watcher_restart`

For detailed troubleshooting, see:
- macOS: This README
- Windows: [README_WINDOWS.md](README_WINDOWS.md)

## 🎯 How It Works

### macOS
1. **Claude Code Hooks** → Create trigger files
2. **fswatch** → Monitors files (event-driven)
3. **afplay** → Plays sounds
4. **Background Process** → All watchers run as one process

### Windows
1. **Claude Code Hooks** → Create trigger files
2. **Polling Loop** → Checks files every 300ms
3. **PowerShell** → Plays sounds via `System.Media.SoundPlayer`
4. **Background Process** → All watchers run as one process

## 📝 Files Structure

```
RedAlert2-Claude/
├── sounds/                          # Shared audio files (both platforms)
│   ├── task-complete.wav
│   ├── session-start.wav
│   ├── vpriata.wav
│   ├── context-compact.wav
│   └── approval-needed.wav
├── ra2-claude-sounds.zsh            # macOS script
├── ra2-claude-sounds-windows.sh     # Windows script
├── install.sh                       # macOS installer
├── install-windows.sh               # Windows installer
├── README.md                        # This file (general documentation)
├── README_WINDOWS.md                # Windows-specific documentation
├── HOOKS.json                       # Claude Code hooks configuration
└── LICENSE
```

## 🆚 Platform Differences

| Feature | macOS | Windows |
|---------|-------|---------|
| File Monitoring | `fswatch` (event-driven) | Polling (300ms) |
| Audio Playback | `afplay` | PowerShell |
| Dependencies | brew, fswatch | None (Git Bash included) |
| Shell | zsh | bash |
| Volume Control | ✅ Supported | ❌ System volume only |

## 🙏 Credits

- **Game**: Command & Conquer: Red Alert 2 by Westwood Studios / EA
- **Inspired by**: StarCraft Claude Sounds projects
- **Audio**: All sounds are from Red Alert 2
- **Windows Port**: Contributed by the community

## 📜 License

**Audio Files**: The included `.wav` files are from Command & Conquer: Red Alert 2, © EA / Westwood Studios. All rights reserved. These files are included under fair use for personal, non-commercial purposes only.

**Code**: MIT License - feel free to use, modify, and distribute the scripts.

## 🎮 Enjoy!

**Kirov reporting!** 🎮🔊

Now enjoy your enhanced Claude Code experience with authentic Red Alert 2 sounds on both macOS and Windows!

---

**Questions or Issues?** Open an issue on GitHub.
