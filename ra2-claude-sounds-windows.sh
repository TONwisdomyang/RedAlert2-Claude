#!/bin/bash
# Claude Code sound notifications - Red Alert 2 Edition (Windows Version)
# Plays Red Alert 2 sounds when Claude starts/completes tasks via file watchers
#
# Version: 2.0 (Optimized & Security-Hardened)

# Configuration - all can be overridden via environment variables
CLAUDE_DIR="$HOME/.claude"

export CLAUDE_SOUNDS_DIR="${CLAUDE_SOUNDS_DIR:-$HOME/.claude/sounds}"
export CLAUDE_SOUND_VOLUME="${CLAUDE_SOUND_VOLUME:-50}"  # 0-100 volume level (for future use)

# Trigger files (created by Claude hooks)
export CLAUDE_DONE_FILE="${CLAUDE_DONE_FILE:-$CLAUDE_DIR/.claude-done}"
export CLAUDE_START_FILE="${CLAUDE_START_FILE:-$CLAUDE_DIR/.claude-start}"
export CLAUDE_PROMPT_FILE="${CLAUDE_PROMPT_FILE:-$CLAUDE_DIR/.claude-prompt}"
export CLAUDE_PRECOMPACT_FILE="${CLAUDE_PRECOMPACT_FILE:-$CLAUDE_DIR/.claude-compact}"
export CLAUDE_APPROVAL_FILE="${CLAUDE_APPROVAL_FILE:-$CLAUDE_DIR/.claude-approval}"

# Sound directories
export CLAUDE_DONE_SOUNDS="${CLAUDE_DONE_SOUNDS:-$CLAUDE_SOUNDS_DIR/done}"
export CLAUDE_START_SOUNDS="${CLAUDE_START_SOUNDS:-$CLAUDE_SOUNDS_DIR/start}"
export CLAUDE_PROMPT_SOUNDS="${CLAUDE_PROMPT_SOUNDS:-$CLAUDE_SOUNDS_DIR/userpromptsubmit}"
export CLAUDE_PRECOMPACT_SOUNDS="${CLAUDE_PRECOMPACT_SOUNDS:-$CLAUDE_SOUNDS_DIR/precompact}"
export CLAUDE_APPROVAL_SOUNDS="${CLAUDE_APPROVAL_SOUNDS:-$CLAUDE_SOUNDS_DIR/approval}"

CLAUDE_WATCHER_PID_FILE="$HOME/.claude_watcher.pid"
CLAUDE_SOUNDS_ENABLED_FILE="$HOME/.claude_sounds_enabled"

# Convert Unix path to Windows path (Git Bash / WSL / Cygwin compatible)
_claude_to_win_path() {
  local unix_path="$1"

  if command -v cygpath &>/dev/null; then
    # Git Bash / Cygwin
    cygpath -w "$unix_path" 2>/dev/null || echo "$unix_path"
  elif [[ "$(uname -r)" =~ Microsoft|WSL ]]; then
    # WSL
    wslpath -w "$unix_path" 2>/dev/null || echo "$unix_path"
  else
    # Fallback: assume path is already Windows-compatible
    echo "$unix_path"
  fi
}

# Play sound using PowerShell (Windows compatible)
_claude_play_sound() {
  local sound_file="$1"

  # Convert to Windows path
  local win_path=$(_claude_to_win_path "$sound_file")

  # Escape single quotes for PowerShell (prevent injection)
  win_path="${win_path//\'/\'\'}"

  # Use PowerShell to play sound in background
  powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "
    try {
      \$player = New-Object System.Media.SoundPlayer '$win_path';
      \$player.Load();
      \$player.PlaySync();
    } catch {
      # Silently ignore playback errors
    }
  " &>/dev/null &
}

# Pick a random sound file from a directory with validation
_claude_random_sound() {
  local dir="$1"

  # Bash array globbing
  shopt -s nullglob
  local files=("$dir"/*.wav "$dir"/*.mp3 "$dir"/*.m4a)
  shopt -u nullglob

  if [ ${#files[@]} -eq 0 ]; then
    return 1
  fi

  # Filter out suspicious files (too small/large)
  # Valid audio files should be between 1KB and 10MB
  local valid_files=()
  for f in "${files[@]}"; do
    if [ -f "$f" ]; then
      local size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo 0)
      if [ "$size" -gt 1000 ] && [ "$size" -lt 10000000 ]; then
        valid_files+=("$f")
      fi
    fi
  done

  if [ ${#valid_files[@]} -eq 0 ]; then
    return 1
  fi

  # Use $RANDOM for simple randomness
  local rand_idx=$((RANDOM % ${#valid_files[@]}))
  echo "${valid_files[$rand_idx]}"
}

# Check if watcher is running
_claude_is_running() {
  [ -f "$CLAUDE_WATCHER_PID_FILE" ] && kill -0 "$(cat "$CLAUDE_WATCHER_PID_FILE")" 2>/dev/null
}

# Generic file watcher with debouncing
_claude_watcher() {
  local watch_file="$1" sound_dir="$2"
  local last_played=0

  while true; do
    if [ -f "$watch_file" ]; then
      local now=$(date +%s)

      # Debounce: ignore if played within last second
      if [ $((now - last_played)) -ge 1 ]; then
        local sound_file=$(_claude_random_sound "$sound_dir")
        if [ -n "$sound_file" ]; then
          _claude_play_sound "$sound_file"
          last_played=$now

          # Wait for PowerShell to start (fix race condition)
          sleep 0.05
        fi
      fi

      # Always remove trigger file
      rm -f "$watch_file"
    fi

    # Poll every 300ms (responsive enough, CPU-friendly)
    sleep 0.3
  done
}

_claude_validate() {
  # Warn about missing sound directories (non-fatal)
  declare -A sound_map=(
    ["done"]="$CLAUDE_DONE_SOUNDS"
    ["start"]="$CLAUDE_START_SOUNDS"
    ["userpromptsubmit"]="$CLAUDE_PROMPT_SOUNDS"
    ["precompact"]="$CLAUDE_PRECOMPACT_SOUNDS"
    ["approval"]="$CLAUDE_APPROVAL_SOUNDS"
  )

  for name in "${!sound_map[@]}"; do
    local dir="${sound_map[$name]}"
    if [ ! -d "$dir" ]; then
      echo "claude-sounds: warning - $name sounds dir not found: $dir" >&2
    fi
  done

  return 0
}

claude_sound_watcher_start() {
  # Already running?
  if _claude_is_running; then
    echo "claude-sounds: already running (PID $(cat "$CLAUDE_WATCHER_PID_FILE"))"
    return 0
  fi

  # Validate dependencies
  _claude_validate || return 1

  # Start watchers in background
  (
    _claude_watcher "$CLAUDE_DONE_FILE" "$CLAUDE_DONE_SOUNDS" &
    _claude_watcher "$CLAUDE_START_FILE" "$CLAUDE_START_SOUNDS" &
    _claude_watcher "$CLAUDE_PROMPT_FILE" "$CLAUDE_PROMPT_SOUNDS" &
    _claude_watcher "$CLAUDE_PRECOMPACT_FILE" "$CLAUDE_PRECOMPACT_SOUNDS" &
    _claude_watcher "$CLAUDE_APPROVAL_FILE" "$CLAUDE_APPROVAL_SOUNDS" &
    wait
  ) &

  local pid=$!
  echo "$pid" > "$CLAUDE_WATCHER_PID_FILE" || {
    echo "claude-sounds: failed to write PID file" >&2
    kill "$pid" 2>/dev/null
    return 1
  }

  echo "claude-sounds: started (PID $pid)"
}

claude_sound_watcher_stop() {
  # Kill by PID file if exists
  if [ -f "$CLAUDE_WATCHER_PID_FILE" ]; then
    local pid=$(cat "$CLAUDE_WATCHER_PID_FILE")

    # Windows-specific: kill entire process tree
    if command -v taskkill &>/dev/null; then
      taskkill //F //T //PID "$pid" &>/dev/null
    else
      # Fallback: try pkill then regular kill
      pkill -P "$pid" 2>/dev/null
      kill -9 "$pid" 2>/dev/null
    fi

    rm -f "$CLAUDE_WATCHER_PID_FILE"
    echo "claude-sounds: stopped"
  else
    echo "claude-sounds: not running"
  fi
}

claude_sound_watcher_restart() {
  claude_sound_watcher_stop
  sleep 1
  claude_sound_watcher_start
}

claude_sound_watcher_status() {
  if _claude_is_running; then
    echo "claude-sounds: running (PID $(cat "$CLAUDE_WATCHER_PID_FILE"))"
    return 0
  else
    echo "claude-sounds: not running"
    return 1
  fi
}

claude_sounds_toggle() {
  if _claude_is_running; then
    claude_sound_watcher_stop
    echo "0" > "$CLAUDE_SOUNDS_ENABLED_FILE"
    echo "claude-sounds: OFF"
  else
    claude_sound_watcher_start
    echo "1" > "$CLAUDE_SOUNDS_ENABLED_FILE"
    echo "claude-sounds: ON"
  fi
}

claude_sound_help() {
  cat <<'EOF'
Claude Code Sound Notifications - Red Alert 2 Edition (Windows)

Commands:
  claude_sound_watcher_start    Start sound watcher
  claude_sound_watcher_stop     Stop sound watcher
  claude_sound_watcher_restart  Restart sound watcher
  claude_sound_watcher_status   Check watcher status
  claude_sounds_toggle (cst)    Toggle sounds on/off
  claude_sound_help             Show this help

Environment Variables:
  CLAUDE_SOUNDS_DIR             Base directory for sounds (default: ~/.claude/sounds)
  CLAUDE_SOUND_VOLUME           Volume level 0-100 (default: 50, reserved for future use)

Sound Event Directories:
  done/              - Task completion sounds
  start/             - Session start sounds
  userpromptsubmit/  - User prompt submission sounds
  precompact/        - Context compaction sounds
  approval/          - Approval request sounds

Test Sounds Manually:
  touch ~/.claude/.claude-done      # Task complete
  touch ~/.claude/.claude-start     # Session start
  touch ~/.claude/.claude-prompt    # Prompt submit
  touch ~/.claude/.claude-compact   # Context compact
  touch ~/.claude/.claude-approval  # Approval needed
EOF
}

# Short alias for quick toggling
alias cst='claude_sounds_toggle'

# Only auto-start if explicitly enabled (default: yes on first run)
if [ ! -f "$CLAUDE_SOUNDS_ENABLED_FILE" ]; then
  # First run: enable by default
  echo "1" > "$CLAUDE_SOUNDS_ENABLED_FILE"
  claude_sound_watcher_start
elif [ "$(cat "$CLAUDE_SOUNDS_ENABLED_FILE")" = "1" ]; then
  claude_sound_watcher_start
fi
