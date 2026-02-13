CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/sounds"
REPO_URL="https://github.com/Lassulus/sounds.git"

# Ensure repo is cloned
ensure_repo() {
  if [ ! -d "$CACHE_DIR/.git" ]; then
    mkdir -p "$CACHE_DIR"
    git clone "$REPO_URL" "$CACHE_DIR"
    git -C "$CACHE_DIR" annex init
    git -C "$CACHE_DIR" config remote.neoprism.annex-uuid "6d741c30-f7c5-40d0-b037-d2c956ee2b2a"
    git -C "$CACHE_DIR" config remote.neoprism.annex-rsyncurl "download@neoprism.lassul.us:annex/sounds"
    git -C "$CACHE_DIR" config remote.neoprism.annex-rsync-transport "ssh -p 45621"
  fi
}

SCRIPT_PATH="${SCRIPT_PATH:-$0}"
export SCRIPT_PATH

if [ -n "${ROFI_RETV:-}" ]; then
  # Called by rofi - SOUND_DIR inherited from environment
  SOUND_DIR="${SOUND_DIR:-$CACHE_DIR}"
  if [ -n "${1:-}" ]; then
    # Fetch synchronously (needs SSH agent), play in background
    file="$SOUND_DIR/$1"
    if [ -L "$file" ] && [ ! -e "$file" ]; then
      git -C "$SOUND_DIR" annex get "$file" &>/dev/null || true
    fi
    mpv --vo=null --no-terminal "$file" &>/dev/null &
    disown
  fi
  # Tell rofi to keep the current selection and filter
  printf '\0keep-selection\x1ftrue\n'
  printf '\0keep-filter\x1ftrue\n'
  find "$SOUND_DIR/games" \( -type f -o -type l \) \( -name "*.wav" -o -name "*.mp3" -o -name "*.ogg" \) 2>/dev/null | sed "s|^$SOUND_DIR/||" | sort
else
  # Initial launch - SOUND_DIR can be passed as argument, or use current dir if it has games/
  if [ -z "${SOUND_DIR:-}" ] && [ -z "${1:-}" ] && [ -d "./games" ]; then
    SOUND_DIR="$(pwd)"
  else
    SOUND_DIR="${SOUND_DIR:-${1:-$CACHE_DIR}}"
  fi
  export SOUND_DIR
  if [ "$SOUND_DIR" = "$CACHE_DIR" ]; then
    ensure_repo
  fi
  rofi -modi "sound:$SCRIPT_PATH" -show sound -i -p "Sound"
fi
