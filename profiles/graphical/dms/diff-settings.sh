#!/usr/bin/env bash
# Show which DMS settings differ between the live (GUI-edited) settings.json
# and the declarative settings.nix, so liked changes can be folded back in.
set -euo pipefail

nix=~/nixfiles/profiles/graphical/dms/settings.nix
live=~/.config/DankMaterialShell/settings.json

declared=$(nix eval --json --file "$nix")

jq -n \
  --argjson a "$declared" \
  --slurpfile b "$live" \
  '($b[0]) as $live
   | reduce ($live | keys[]) as $k ({};
       if ($a[$k] != $live[$k]) then . + {($k): $live[$k]} else . end)'
