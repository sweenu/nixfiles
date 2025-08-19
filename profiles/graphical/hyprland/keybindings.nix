{ config, pkgs }:
let
  screenshotFolderPath = "${config.vars.home}/${config.vars.screenshotFolder}";
  screencastFolderPath = "${config.vars.home}/${config.vars.screencastFolder}";
  capture = "${pkgs.capture}/bin/capture";
  choose-capture = "${pkgs.choose-capture}/bin/choose-capture";
  backlight = "${pkgs.backlight}/bin/backlight";
  soundcards = "${pkgs.soundcards}/bin/soundcards";
  light = "${pkgs.light}/bin/light";
  makoctl = "${pkgs.mako}/bin/makoctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  ddcciDeviceQuery = "${light} -L | ${pkgs.ripgrep}/bin/rg ddcci | awk '{$1=$1};1'";
  ddcciLight = action: ''${light} -s $(${ddcciDeviceQuery}) ${action} || notify-send "Hyprland" "Could not find ddcci device"'';
in
{
  # Keybindings
  bind = [
    # Kill focused window
    "$mod, X, killactive"

    # Reload configuration
    "$mod SHIFT, R, exec, hyprctl reload"

    # Exit Hyprland
    "$mod SHIFT, Q, exit"

    # Focus movement
    "$mod, H, movefocus, l"
    "$mod, J, movefocus, d"
    "$mod, K, movefocus, u"
    "$mod, L, movefocus, r"

    # Move windows
    "$mod SHIFT, H, movewindow, l"
    "$mod SHIFT, J, movewindow, d"
    "$mod SHIFT, K, movewindow, u"
    "$mod SHIFT, L, movewindow, r"

    # Workspace switching
    "$mod, A, workspace, 1"
    "$mod, S, workspace, 2"
    "$mod, D, workspace, 3"
    "$mod, F, workspace, 4"
    "$mod, U, workspace, 5"
    "$mod, I, workspace, 6"
    "$mod, O, workspace, 7"
    "$mod, P, workspace, 8"
    "$mod, M, workspace, 9"

    # Move to workspace
    "$mod SHIFT, A, movetoworkspacesilent, 1"
    "$mod SHIFT, S, movetoworkspacesilent, 2"
    "$mod SHIFT, D, movetoworkspacesilent, 3"
    "$mod SHIFT, F, movetoworkspacesilent, 4"
    "$mod SHIFT, U, movetoworkspacesilent, 5"
    "$mod SHIFT, I, movetoworkspacesilent, 6"
    "$mod SHIFT, O, movetoworkspacesilent, 7"
    "$mod SHIFT, P, movetoworkspacesilent, 8"

    "$mod CTRL SHIFT, A, movetoworkspace, 1"
    "$mod CTRL SHIFT, S, movetoworkspace, 2"
    "$mod CTRL SHIFT, D, movetoworkspace, 3"
    "$mod CTRL SHIFT, F, movetoworkspace, 4"
    "$mod CTRL SHIFT, U, movetoworkspace, 5"
    "$mod CTRL SHIFT, I, movetoworkspace, 6"
    "$mod CTRL SHIFT, O, movetoworkspace, 7"
    "$mod CTRL SHIFT, P, movetoworkspace, 8"

    # Layout controls
    "$mod SHIFT, J, layoutmsg, togglesplit"
    "$mod SHIFT, H, layoutmsg, swapsplit"
    "$mod, V, layoutmsg, preselect d"
    "$mod, TAB, fullscreen, 1"
    ", F11, fullscreen"

    # Apps
    "$mod, Return, exec, $terminal"
    "$mod, T, exec, $menu"
    "$mod, B, exec, firefox"

    # Mako notifications
    "$mod, period, exec, ${makoctl} restore"
    "$mod SHIFT, period, exec, ${makoctl} menu ${pkgs.wofi}/bin/wofi -d -p 'Choose Action: '"
    "$mod, Space, exec, ${makoctl} dismiss"
    "$mod SHIFT, Space, exec, ${makoctl} dismiss --all"

    # Soundcards
    "$mod, bracketleft, exec, ${soundcards} previous"
    "$mod, bracketright, exec, ${soundcards} next"
    ", F10, exec, ${soundcards} toggle-hdmi"

    # Screen capture
    ", Print, exec, ${capture} -o ${screenshotFolderPath}"
    "$mod, Home, exec, ${capture} -o ${screenshotFolderPath}"
    "$mod, Print, exec, ${capture} -o ${screenshotFolderPath} slurped-screenshot"
    "$mod SHIFT, Home, exec, ${capture} -o ${screenshotFolderPath} slurped-screenshot"
    "$mod SHIFT, Print, exec, ${choose-capture} ${screenshotFolderPath} ${screencastFolderPath}"

    # Turn off laptop screen
    ", F9, exec, hyprctl dispatch dpms toggle eDP-1"
    ", XF86Display, exec, hyprctl dispatch dpms toggle eDP-1"

    # Inhibit suspend
    ", F12, exec, ${pkgs.inhibit}/bin/inhibit"
    ", XF86AudioMedia, exec, ${pkgs.inhibit}/bin/inhibit"

    # Scratchpad equivalent (special workspace)
    "$mod SHIFT, minus, movetoworkspace, special:scratchpad"
    "$mod, minus, togglespecialworkspace, scratchpad"

    # Submaps
    "$mod, W, submap, window"
    "$mod, Escape, submap, system"
  ];

  bindl = [
    ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_SINK@ toggle"
    ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_SOURCE@ toggle"
    ", XF86AudioPlay, exec, ${playerctl} play-pause"
    ", XF86AudioNext, exec, ${playerctl} next"
    ", XF86AudioPrev, exec, ${playerctl} previous"
  ];

  bindle = [
    # Volume
    ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_SINK@ 5%-"
    # Backlight
    ", XF86MonBrightnessUp, exec, ${backlight} inc"
    ", XF86MonBrightnessDown, exec, ${backlight} dec"
    "$mod SHIFT, Up, exec, ${ddcciLight "-A 5"}"
    "$mod SHIFT, Down, exec, ${ddcciLight "-U 5"}"
  ];

  binde = [
    # Resizing windows
    "$mod, left, resizeactive, -10 0"
    "$mod, right, resizeactive, 10 0"
    "$mod, up, resizeactive, 0 -10"
    "$mod, down, resizeactive, 0 10"
  ];

  bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];
}
