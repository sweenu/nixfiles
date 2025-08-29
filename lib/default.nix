final: prev: {
  lib = prev.lib.extend (lfinal: lprev:
    {
      hyprMoveWsToMonitor = ws: monitor: "hyprctl dispatch moveworkspacetomonitor ${ws} ${monitor}";
    });
}
