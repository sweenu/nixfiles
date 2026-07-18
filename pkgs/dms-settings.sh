#!/usr/bin/env bash
# Manage the declarative DankMaterialShell config from the live shell.
#
# DMS's settings.json and plugin_settings.json are read-only Nix store symlinks,
# so GUI edits never hit disk -- they live only in the running process. These
# commands read that state over IPC (requires DankMaterialShell >= 1.5.1) so you
# can review and persist the tweaks you like.
set -euo pipefail

dir=$HOME/nixfiles/profiles/graphical/dms
settings=${DMS_SETTINGS:-$dir/settings.json}
plugins=${DMS_PLUGIN_SETTINGS:-$dir/plugin_settings.json}

# Runtime bookkeeping DMS rewrites on every settings change (greeter sync
# tracking); never a real setting, so keep it out of the declared files.
ignore='del(.greeterSyncPending, .greeterSyncBaseline)'

die() {
  echo "$*" >&2
  exit 1
}

# Echo valid JSON from `dms ipc call settings $*` (minus ignored keys), or die.
live() {
  local out
  out=$(dms ipc call settings "$@" 2>/dev/null) || true
  jq -e . >/dev/null 2>&1 <<<"$out" ||
    die "Couldn't read live settings -- is DankMaterialShell (>=1.5.1) running?"
  jq -c "$ignore" <<<"$out"
}

# List the leaf paths whose live value differs from the declared file. Recurses
# through objects and equal-length arrays, so it points at the smallest changed
# subtree (e.g. barConfigs.0.rightWidgets) rather than dumping the whole key.
diff_against() {
  local file=$1 json=$2 declared
  declared=$(jq "$ignore" "$file")
  jq -n --argjson d "$declared" --argjson l "$json" '
    def diff($d; $l; $p):
      if $d == $l then empty
      elif ($d|type) == "object" and ($l|type) == "object" then
        (($d|keys) + ($l|keys) | unique)[] as $k | diff($d[$k]; $l[$k]; $p + [$k])
      elif ($d|type) == "array" and ($l|type) == "array" and ($d|length) == ($l|length) then
        range(0; $d|length) as $i | diff($d[$i]; $l[$i]; $p + [$i])
      else { path: ($p | join(".")), declared: $d, live: $l }
      end;
    [ diff($d; $l; []) ]'
}

dump_to() {
  local file=$1 json=$2
  jq -S . <<<"$json" >"$file.tmp"
  mv "$file.tmp" "$file"
  echo "Wrote live settings into $file -- review with: git diff ${file/#$HOME/\~}"
}

json=
case "${1:-}" in
  diff) json=$(live dump); diff_against "$settings" "$json" ;;
  dump) json=$(live dump); dump_to "$settings" "$json" ;;
  diff-plugins) json=$(live get pluginSettings); diff_against "$plugins" "$json" ;;
  dump-plugins) json=$(live get pluginSettings); dump_to "$plugins" "$json" ;;
  *)
    cat >&2 <<EOF
Usage: dms-settings <command>

  diff           Preview settings.json changes made in the GUI but not yet saved
  dump           Overwrite settings.json with the live in-memory state
  diff-plugins   Same as diff, for plugin_settings.json
  dump-plugins   Same as dump, for plugin_settings.json

Review dumps with git diff. Override targets via \$DMS_SETTINGS / \$DMS_PLUGIN_SETTINGS.
EOF
    exit 1
    ;;
esac
