SOUND_DIR="${SOUND_DIR:-${1:-$(pwd)}}"
export SOUND_DIR
SCRIPT_PATH="${SCRIPT_PATH:-$0}"
export SCRIPT_PATH

if [ -n "${ROFI_RETV:-}" ]; then
  # Called by rofi with a selection
  if [ -n "${1:-}" ]; then
    systemd-run --user --no-block --quiet -- mpv --vo=null --no-terminal "$SOUND_DIR/$1" &>/dev/null
  fi
  # Tell rofi to keep the current selection and filter
  printf '\0keep-selection\x1ftrue\n'
  printf '\0keep-filter\x1ftrue\n'
  find "$SOUND_DIR/games" \( -type f -o -type l \) \( -name "*.wav" -o -name "*.mp3" -o -name "*.ogg" \) 2>/dev/null | sed "s|^$SOUND_DIR/||" | sort
else
  # Initial launch
  if [ ! -d "$SOUND_DIR/games" ]; then
    echo "Error: No 'games' directory found in $SOUND_DIR" >&2
    echo "Usage: board-rofi [path-to-sounds-directory]" >&2
    exit 1
  fi
  rofi -modi "sound:$SCRIPT_PATH" -show sound -i -p "Sound"
fi
