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

# Determine SOUND_DIR
if [ -z "${SOUND_DIR:-}" ] && [ -z "${1:-}" ] && [ -d "./games" ]; then
  SOUND_DIR="$(pwd)"
else
  SOUND_DIR="${SOUND_DIR:-${1:-$CACHE_DIR}}"
fi

if [ "$SOUND_DIR" = "$CACHE_DIR" ]; then
  ensure_repo
fi

export SOUND_DIR
find "$SOUND_DIR/games" \( -type f -o -type l \) \( -name "*.wav" -o -name "*.mp3" -o -name "*.ogg" \) 2>/dev/null \
  | sed "s|^$SOUND_DIR/||" \
  | sort \
  | fzf --prompt="Sound> " \
      --bind "enter:execute-silent(play-sound {})+refresh-preview" \
      --preview "echo {}" \
      --preview-window=hidden
