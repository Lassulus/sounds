#!/usr/bin/env bash
# peon-ping hook for Claude Code on Linux
# Plays Warcraft III Peon voice lines on Claude Code events
# Uses pw-play (PipeWire) for audio and notify-send for desktop notifications

set -euo pipefail

SOUND_DIR="$HOME/src/sounds/peon"

# Read hook event from stdin JSON
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
NTYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Derive project name from cwd (last directory component)
PROJECT="${CWD##*/}"
PROJECT="${PROJECT:-unknown}"

# Map event to sound category and whether to show a desktop notification
NOTIFY=""
case "$EVENT" in
  SessionStart)
    SOUNDS=(PeonReady1.wav PeonWhat1.wav PeonWhat3.wav)
    ;;
  UserPromptSubmit)
    SOUNDS=(PeonYes1.wav PeonYes2.wav PeonYes3.wav PeonYes4.wav PeonYesAttack1.wav PeonYesAttack2.wav PeonYesAttack3.wav)
    ;;
  Stop)
    SOUNDS=(PeonReady1.wav PeonWhat4.wav PeonYes1.wav PeonYes2.wav PeonYes3.wav PeonYesAttack1.wav PeonYesAttack3.wav)
    ;;
  Notification)
    if [[ "$NTYPE" == "permission_prompt" ]]; then
      SOUNDS=(PeonWhat4.wav PeonWhat2.wav PeonWhat3.wav PeonWhat1.wav)
      NOTIFY="Permission needed"
    elif [[ "$NTYPE" == "idle_prompt" ]]; then
      SOUNDS=(PeonWhat4.wav PeonWhat2.wav PeonWhat3.wav PeonWhat1.wav)
      NOTIFY="Needs attention"
    else
      exit 0
    fi
    ;;
  *)
    exit 0
    ;;
esac

# Pick a random sound
SOUND="${SOUNDS[$((RANDOM % ${#SOUNDS[@]}))]}"
SOUND_FILE="$SOUND_DIR/$SOUND"

# Play sound in background (non-blocking)
if [[ -f "$SOUND_FILE" ]]; then
  pw-play "$SOUND_FILE" &>/dev/null &
fi

# Send desktop notification only for events that need user action
if [[ -n "$NOTIFY" ]]; then
  notify-send -t 5000 "Claude Code [$PROJECT]" "$NOTIFY" &>/dev/null || true
fi

exit 0
