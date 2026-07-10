#!/usr/bin/env bash
# Show which DMS settings you've changed in the GUI but not yet folded into the
# declarative config. settings.json is a read-only store symlink, so GUI edits
# never hit disk -- they live only in the running DMS process. We read that live
# state over IPC (settings get <key>) and diff it against settings.nix, printing
# the changed keys with their live values so you can port the ones you like.
set -euo pipefail

nix=~/nixfiles/profiles/graphical/dms/settings.nix

if ! dms ipc call settings get theme >/dev/null 2>&1; then
  echo "DMS IPC not reachable -- is DankMaterialShell running?" >&2
  exit 1
fi

declared=$(nix eval --json --file "$nix")

# Query every declared key from live memory, building a {key: liveValue} object.
live=$(
  jq -r 'keys[]' <<<"$declared" | while read -r k; do
    v=$(dms ipc call settings get "$k" 2>/dev/null)
    [ "$v" = "undefined" ] && continue
    jq -cn --arg k "$k" --argjson v "$v" '{($k): $v}'
  done | jq -s 'add // {}'
)

# Emit only the keys whose live value differs from the declarative one.
jq -n --argjson a "$declared" --argjson l "$live" '
  reduce ($l | keys[]) as $k ({};
    if $a[$k] != $l[$k] then . + {($k): $l[$k]} else . end)'
