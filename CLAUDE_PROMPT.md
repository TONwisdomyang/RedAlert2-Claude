# 🤖 Instructions for AI Assistants (Claude Code)

This document provides instructions for AI assistants (like Claude) on how to help users install, configure, and troubleshoot the Red Alert 2 Sound System for Claude Code.

## 📋 What This System Does

This project adds Red Alert 2 sound effects to Claude Code events:
- **Task Complete** → Building placement sound (`uplace.wav`)
- **Session Start** → GI "Ready!" sound (`igidepa.wav`)
- **Prompt Submit** → Prism Tank "Calculating Reflection Arcs!" (`vpriata.wav`)
- **Context Compact** → Nuclear Silo Ready EVA voice (`snukread.wav`)

## 🎯 When Users Ask for Help

### Installation Questions

**If user asks**: "How do I install the RA2 sound system?"

**You should**:
1. Check if they have fswatch: `fswatch --version`
2. If not, help them install: `brew install fswatch`
3. Guide them to run: `./install.sh`
4. Then: `source ~/.zshrc`
5. Verify: `claude_sound_watcher_status`

**Example Response**:
```
Let me help you install the Red Alert 2 sound system. First, let me check if you have fswatch installed.
```

Then run the checks and guide them through the installation.

### Troubleshooting

**If sounds aren't playing**:

1. **Check fswatch installation**
   ```bash
   fswatch --version
   ```
   If not found → `brew install fswatch`

2. **Check watcher status**
   ```bash
   source ~/.zshrc && claude_sound_watcher_status
   ```
   If not running → `claude_sound_watcher_start`

3. **Check audio files**
   ```bash
   ls -lh ~/.claude/sounds/*/
   ```
   Should show 4 files (one in each directory)

4. **Check hooks configuration**
   ```bash
   cat ~/.claude/settings.json | grep -A 5 hooks
   ```
   Should show the 4 hook configurations

5. **Test manually**
   ```bash
   touch ~/.claude/.claude-prompt
   ```
   Should hear Prism Tank sound

**Common Issues**:

| Issue | Diagnosis | Solution |
|-------|-----------|----------|
| No sound | Watcher not running | `claude_sound_watcher_start` |
| No sound | Audio files missing | Re-run `./install.sh` |
| Too loud/quiet | Volume not adjusted | `export CLAUDE_SOUND_VOLUME=0.2` then restart |
| Functions not found | zshrc not loaded | `source ~/.zshrc` |

### Volume Adjustment

**If user says**: "The sounds are too loud/quiet"

**You should**:
1. Help them add to `~/.zshrc`:
   ```bash
   export CLAUDE_SOUND_VOLUME=0.2  # 20% volume
   ```
2. Reload: `source ~/.zshrc`
3. Restart: `claude_sound_watcher_restart`

### Adding More Sounds

**If user wants**: "Can I add more Red Alert 2 sounds?"

**You should**:
1. Explain they can add any `.wav` file to the directories
2. Show the directories:
   ```
   ~/.claude/sounds/done/          # Task complete sounds
   ~/.claude/sounds/start/         # Session start sounds
   ~/.claude/sounds/userpromptsubmit/  # Prompt submit sounds
   ~/.claude/sounds/precompact/    # Context compact sounds
   ```
3. Explain the system picks randomly if multiple files exist

## 🔍 Diagnostic Commands

When helping users troubleshoot, use these commands to gather information:

```bash
# Check installation status
ls -lh ~/.claude/sounds/*/

# Check watcher process
ps aux | grep fswatch | grep -v grep

# Check if hooks are configured
cat ~/.claude/settings.json | jq '.hooks'

# Check if zsh script is loaded
type claude_sound_watcher_status

# Test each sound
touch ~/.claude/.claude-done
touch ~/.claude/.claude-start
touch ~/.claude/.claude-prompt
touch ~/.claude/.claude-compact
```

## 📝 File Locations Reference

| File/Directory | Purpose |
|----------------|---------|
| `~/.claude/sounds/done/` | Task complete sounds |
| `~/.claude/sounds/start/` | Session start sounds |
| `~/.claude/sounds/userpromptsubmit/` | Prompt submit sounds |
| `~/.claude/sounds/precompact/` | Context compact sounds |
| `~/.ra2-claude-sounds.zsh` | Main script with watcher functions |
| `~/.claude/settings.json` | Claude Code hooks configuration |
| `~/.claude-sounds-state` | ON/OFF state persistence file |
| `~/.claude/.claude-*` | Temporary trigger files (auto-deleted) |

## 🚫 What NOT to Do

**DO NOT**:
- Suggest modifying the `ra2-claude-sounds.zsh` script unless necessary
- Recommend deleting `~/.claude/settings.json` (may have other configs)
- Use `killall fswatch` (might kill other user processes)
- Suggest using different audio formats (only `.wav` supported)

**DO**:
- Use the provided functions (`claude_sound_watcher_*`)
- Check before making changes
- Preserve existing user configurations
- Test before confirming fixes

## 🎮 Expected Behavior

When working correctly:

1. **On Claude Code start or `/clear`**:
   - Trigger file created: `~/.claude/.claude-start`
   - Sound plays: GI "Ready!"
   - Trigger file auto-deleted

2. **When user submits a prompt**:
   - Trigger file created: `~/.claude/.claude-prompt`
   - Sound plays: Prism Tank "Calculating Reflection Arcs!"
   - Trigger file auto-deleted

3. **When Claude finishes responding**:
   - Trigger file created: `~/.claude/.claude-done`
   - Sound plays: Building placement sound
   - Trigger file auto-deleted

4. **Before context compression**:
   - Trigger file created: `~/.claude/.claude-compact`
   - Sound plays: Nuclear Silo Ready (EVA voice)
   - Trigger file auto-deleted

## 🔧 Advanced Troubleshooting

### If watcher keeps dying

```bash
# Check logs
tail -f /tmp/claude-sounds.log  # If logging is enabled

# Check for conflicts
ps aux | grep fswatch

# Restart with verbose mode (if implemented)
claude_sound_watcher_stop
# Manually start to see errors
fswatch -o ~/.claude/.claude-done ~/.claude/.claude-start ~/.claude/.claude-prompt ~/.claude/.claude-compact
```

### If settings.json already exists

**Don't overwrite!** Instead:
1. Read existing content: `cat ~/.claude/settings.json`
2. Help user merge the hooks manually
3. Use `jq` if available to merge JSON
4. Or guide them to manually add the hooks section

### If audio files are corrupted

```bash
# Test audio playback directly
afplay ~/.claude/sounds/done/uplace.wav

# If fails, re-run installation
cd /path/to/ra2-claude-sounds
./install.sh
```

## 💡 Helpful Tips for Users

When appropriate, share these tips:

1. **Quick toggle**: `cst` is the fastest way to turn sounds on/off
2. **Persistent settings**: State is saved in `~/.claude-sounds-state`
3. **Multiple sounds**: Drop multiple `.wav` files in a directory for variety
4. **Volume control**: Adjust before starting watcher, not after
5. **Manual testing**: Use `touch ~/.claude/.claude-*` to test without using Claude

## 📚 Related Documentation

- **README.md**: User-facing installation and usage guide
- **HOOKS.json**: Example hooks configuration for `settings.json`
- **install.sh**: Automated installation script

## 🎯 Success Criteria

Installation is successful when:
- ✅ `claude_sound_watcher_status` shows "running"
- ✅ All 4 sound files exist in `~/.claude/sounds/*/`
- ✅ Hooks are configured in `~/.claude/settings.json`
- ✅ Manual trigger test (`touch ~/.claude/.claude-prompt`) plays sound
- ✅ `cst` command toggles sounds on/off

## 🚀 Quick Reference

**Common Commands**:
```bash
cst                              # Toggle sounds
claude_sound_watcher_status      # Check status
claude_sound_watcher_restart     # Restart watcher
source ~/.zshrc                  # Reload configuration
```

**Common Files**:
```bash
~/.claude/settings.json          # Hooks config
~/.ra2-claude-sounds.zsh         # Main script
~/.claude/sounds/                # Sound files directory
```

**Test Sounds**:
```bash
touch ~/.claude/.claude-prompt   # Prism Tank
touch ~/.claude/.claude-done     # Building placement
touch ~/.claude/.claude-start    # GI Ready
touch ~/.claude/.claude-compact  # Nuclear Silo
```

---

**Remember**: Always verify state before making changes, and preserve user's existing configurations!

**Kirov reporting!** 🎮🔊
