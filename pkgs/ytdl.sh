# YouTube downloader for the phone, run by sharing a link to nix-on-droid.
# Adapted from Termux-YTD2.0 (https://github.com/khansaad1275/Termux-YTD2.0, MIT).
#
# yt-dlp lives in its own nix profile instead of the nix-on-droid config so it
# can be upgraded the moment YouTube breaks it, with `ytdl --upgrade`.

profile="$HOME/.local/state/nix/profiles/yt-dlp"
dest="$HOME/storage/shared/Youtube"

# Shared links run in a session that closes on exit, so keep errors readable.
set -o errtrace
trap 'read -rp "Something went wrong, press Enter to close." _' ERR

if [[ "${1:-}" == "--upgrade" ]]; then
  nix profile upgrade --profile "$profile" --all
  exit
fi

if [[ $# -ne 1 ]]; then
  echo "usage: ytdl URL | ytdl --upgrade" >&2
  exit 1
fi
url="$1"

if [[ ! -x "$profile/bin/yt-dlp" ]]; then
  echo "Installing yt-dlp..."
  mkdir -p "$(dirname "$profile")"
  nix profile add --profile "$profile" github:NixOS/nixpkgs/nixpkgs-unstable#yt-dlp
fi

if [[ ! -d "$HOME/storage/shared" ]]; then
  echo "No access to shared storage, run termux-setup-storage first." >&2
  false
fi
mkdir -p "$dest"

download() {
  "$profile/bin/yt-dlp" -o "$dest/%(title)s.%(ext)s" "$@" "$url"
}

# YouTube only serves 360p as a single file, so get video and audio separately
# and let yt-dlp merge them.
video() {
  download -f "bv*[height<=$1]+ba/b[height<=$1]" --merge-output-format mp4
}

if [[ "$url" == *shorts* ]]; then
  download
  exit
fi

echo "1. Music mp3"
echo "2. Video 360p"
echo "3. Video 480p"
echo "4. Video 720p"
echo "5. Video 1080p"
echo "6. Video 2160p"
echo "7. Exit"
read -rp "> " choice

case "$choice" in
  1) download -x --audio-format mp3 ;;
  2) video 360 ;;
  3) video 480 ;;
  4) video 720 ;;
  5) video 1080 ;;
  6) video 2160 ;;
  *) exit ;;
esac
