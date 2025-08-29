{ config, pkgs }:
let
  soundcards = "${pkgs.soundcards}/bin/soundcards";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  backlight = "${pkgs.backlight}/bin/backlight";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  ddcciDeviceQuery = "${brightnessctl} -l | ${pkgs.ripgrep}/bin/rg ddcci | awk '{$1=$1};1'";
  ddcciLight = action: ''${brightnessctl} -d $(${ddcciDeviceQuery}) ${action} || notify-send "Hyprland" "Could not find ddcci device"'';
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
    "${mod}, T, global, caelestia:launcher"
    "${mod}, Return, exec, app2unit -- ${config.vars.terminalBin}"
    "${mod}, B, exec, app2unit -- firefox"
    "${mod}, N, exec, app2unit -- obsidian"
    "${mod}, Z, exec, app2unit -- zeditor"
    "${mod} SHIFT, Escape, exec, app2unit -- ${pkgs.mission-center}/bin/missioncenter"

    # Notifications
    "${mod}, Space, global, caelestia:clearNotifs"

    # Soundcards
    "${mod}, bracketleft, exec, ${soundcards} previous"
    "${mod}, bracketright, exec, ${soundcards} next"
    ", F10, exec, ${soundcards} toggle-hdmi"

    # Screen capture
    ", Print, exec, caelestia screenshot" # Fullscreen screenshot
    "${mod}, Print, global, caelestia:screenshot"
    "${mod} SHIFT, Print, global, caelestia:screenshotFreeze"

    # Turn off laptop screen
    ", F9, exec, hyprctl dispatch dpms toggle eDP-1"

    # Inhibit suspend
    ", F12, exec, caelestia shell idleInhibitor toggle"
    ", XF86AudioMedia, exec, caelestia shell idleInhibitor toggle"

    # Special workspace
    "${mod}, minus, togglespecialworkspace, signal"
    "${mod}, M, togglespecialworkspace, spotify"

    # Submaps
    "${mod}, W, submap, window"

    # Caelestia
    "${mod}, Escape, global, caelestia:session"
    "${mod}, Period, exec, caelestia emoji -p"
  ];

  bindl = [
    ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_SINK@ toggle"
    ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_SOURCE@ toggle"
    ", XF86AudioPlay, global, caelestia:mediaToggle"
    ", XF86AudioNext, global, caelestia:mediaNext"
    ", XF86AudioPrev, global, caelestia:mediaPrev"
    ", XF86AudioStop, global, caelestia:mediaStop"
  ];

  bindle = [
    # Volume
    ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_SINK@ 5%-"
    # Backlight
    ", XF86MonBrightnessUp, exec, ${backlight} inc"
    ", XF86MonBrightnessDown, exec, ${backlight} dec"
    "${mod} SHIFT, Up, exec, ${ddcciLight "-s +5%"}"
    "${mod} SHIFT, Down, exec, ${ddcciLight "-s -5%"}"
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
