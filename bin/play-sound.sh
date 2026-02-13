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

# Fetch a single sound file if not available
ensure_sound() {
  local file="$1"
  if [ -L "$file" ] && [ ! -e "$file" ]; then
    git -C "$SOUND_DIR" annex get "$file"
  fi
}

SOUND_DIR="${SOUND_DIR:-$CACHE_DIR}"

if [ -z "${1:-}" ]; then
  echo "Usage: play-sound <path-to-sound>" >&2
  exit 1
fi

if [ "$SOUND_DIR" = "$CACHE_DIR" ]; then
  ensure_repo
fi
ensure_sound "$SOUND_DIR/$1"
exec mpv --vo=null --no-terminal "$SOUND_DIR/$1"
