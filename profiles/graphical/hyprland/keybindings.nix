{ config, pkgs }:
let
  backlight = "${pkgs.backlight}/bin/backlight";
  dms = "dms ipc call";
  mod = "SUPER";
in
{
  # Keybindings
  bind = [
    # Kill focused window
    "${mod}, X, killactive"

    # Reload configuration
    "${mod} SHIFT, R, exec, hyprctl reload"

    # Exit Hyprland
    "${mod} SHIFT, Q, exit"

    # Focus movement
    "${mod}, H, movefocus, l"
    "${mod}, J, movefocus, d"
    "${mod}, K, movefocus, u"
    "${mod}, L, movefocus, r"

    # Move windows
    "${mod} SHIFT, H, movewindow, l"
    "${mod} SHIFT, J, movewindow, d"
    "${mod} SHIFT, K, movewindow, u"
    "${mod} SHIFT, L, movewindow, r"

    # Workspace switching
    "${mod}, A, workspace, 1"
    "${mod}, S, workspace, 2"
    "${mod}, D, workspace, 3"
    "${mod}, F, workspace, 4"
    "${mod}, U, workspace, 5"
    "${mod}, I, workspace, 6"
    "${mod}, O, workspace, 7"
    "${mod}, P, workspace, 8"

    # Move to workspace
    "${mod} SHIFT, A, movetoworkspacesilent, 1"
    "${mod} SHIFT, S, movetoworkspacesilent, 2"
    "${mod} SHIFT, D, movetoworkspacesilent, 3"
    "${mod} SHIFT, F, movetoworkspacesilent, 4"
    "${mod} SHIFT, U, movetoworkspacesilent, 5"
    "${mod} SHIFT, I, movetoworkspacesilent, 6"
    "${mod} SHIFT, O, movetoworkspacesilent, 7"
    "${mod} SHIFT, P, movetoworkspacesilent, 8"

    "${mod} CTRL SHIFT, A, movetoworkspace, 1"
    "${mod} CTRL SHIFT, S, movetoworkspace, 2"
    "${mod} CTRL SHIFT, D, movetoworkspace, 3"
    "${mod} CTRL SHIFT, F, movetoworkspace, 4"
    "${mod} CTRL SHIFT, U, movetoworkspace, 5"
    "${mod} CTRL SHIFT, I, movetoworkspace, 6"
    "${mod} CTRL SHIFT, O, movetoworkspace, 7"
    "${mod} CTRL SHIFT, P, movetoworkspace, 8"

    # Layout controls
    "${mod}, V, layoutmsg, togglesplit"
    "${mod} SHIFT, V, layoutmsg, preselect d"
    "${mod}, TAB, fullscreen, 1"
    ", F11, fullscreen"

    # Apps
    "${mod}, Space, exec, ${dms} spotlight toggle"
    "${mod}, Return, exec, app2unit -- ${config.vars.terminalBin}"
    "${mod}, B, exec, app2unit -- ${config.vars.defaultBrowser}"
    "${mod}, N, exec, app2unit -- obsidian"
    "${mod}, Z, exec, app2unit -- zeditor"
    "${mod} SHIFT, Escape, exec, app2unit -- ${dms} processlist open"

    # Notifications
    "${mod}, Comma, exec, ${dms} notifications clearAll"
    "${mod}, Period, exec, ${dms} notifications toggle"

    # Soundcards
    "${mod}, bracketleft, exec, ${dms} audio cycleoutput"
    "${mod}, bracketright, exec, ${dms} audio cycleoutput"

    # Screen capture
    ", Print, exec, dms screenshot full" # Fullscreen screenshot
    "${mod}, Print, exec, dms screenshot"

    # Turn off laptop screen
    ", F9, exec, hyprctl dispatch dpms toggle eDP-1"

    # Inhibit suspend
    ", F12, exec, ${dms} inhibit toggle"
    ", XF86AudioMedia, exec, ${dms} inhibit toggle"

    # Special workspace
    "${mod}, minus, togglespecialworkspace, communication"
    "${mod}, M, togglespecialworkspace, music"

    # Submaps
    "${mod}, W, submap, window"

    # DMS
    "${mod}, ?, exec, ${dms} keybinds toggle hyprland"
    "${mod}, Escape, exec, ${dms} powermenu toggle"
  ];

  bindl = [
    ", XF86AudioMute, exec, ${dms} audio mute"
    ", XF86AudioMicMute, exec, ${dms} audio micmute"
    ", XF86AudioPlay, exec, ${dms} mpris playPause"
    ", XF86AudioNext, exec, ${dms} mpris next"
    ", XF86AudioPrev, exec, ${dms} mpris previous"
    ", XF86AudioStop, exec, ${dms} mpris stop"
  ];

  bindle = [
    # Volume
    ", XF86AudioRaiseVolume, exec, ${dms} audio increment 5"
    ", XF86AudioLowerVolume, exec, ${dms} audio decrement 5"
    # Backlight
    ", XF86MonBrightnessUp, exec, ${backlight} inc"
    ", XF86MonBrightnessDown, exec, ${backlight} dec"
    "SHIFT, XF86MonBrightnessUp, exec, ${dms} brightness increment 5 'ddc:i2c-15'"
    "SHIFT, XF86MonBrightnessDown, exec, ${dms} brightness decrement 5 'ddc:i2c-15'"
  ];

  binde = [
    # Resizing windows
    "${mod}, left, resizeactive, -10 0"
    "${mod}, right, resizeactive, 10 0"
    "${mod}, up, resizeactive, 0 -10"
    "${mod}, down, resizeactive, 0 10"
  ];

  bindm = [
    "${mod}, mouse:272, movewindow"
    "${mod}, mouse:273, resizewindow"
  ];
}
