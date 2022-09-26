{ config, pkgs }:

let
  cfg = config.home-manager.users."${config.vars.username}".wayland.windowManager.sway.config;
  mod = cfg.modifier;
  screenshotFolderPath = "${config.vars.home}/${config.vars.screenshotFolder}";
  screencastFolderPath = "${config.vars.home}/${config.vars.screencastFolder}";
  sway-capture = "${pkgs.sway-capture}/bin/sway-capture";
  sway-choose-capture = "${pkgs.sway-choose-capture}/bin/sway-choose-capture";
  sway-backlight = "${pkgs.sway-backlight}/bin/sway-backlight";
  sway-soundcards = "${pkgs.sway-soundcards}/bin/sway-soundcards";
  sway-app-or-workspace = "${pkgs.sway-app-or-workspace}/bin/sway-app-or-workspace";
  light = "${pkgs.light}/bin/light";
  makoctl = "${pkgs.mako}/bin/makoctl";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  ddcciDeviceQuery = "${light} -L | ${pkgs.ripgrep}/bin/rg ddcci | awk '{$1=$1};1'";
  ddcciLight = action: ''
    ${light} -s $(${ddcciDeviceQuery}) ${action} || notify-send "Sway" "Could not find ddcci device"
  '';
in
rec {
  # Kill focused window
  "${mod}+x" = "kill";

  # Reload the configuration file
  "${mod}+Shift+r" = "reload";

  # Exit sway
  "${mod}+Shift+q" = "exit";

  ### Moving around
  # Move your focus around
  "${mod}+h" = "focus left";
  "${mod}+j" = "focus down";
  "${mod}+k" = "focus up";
  "${mod}+l" = "focus right";

  # Move the focused window with the same, but add Shift
  "${mod}+Shift+h" = "move left";
  "${mod}+Shift+j" = "move down";
  "${mod}+Shift+k" = "move up";
  "${mod}+Shift+l" = "move right";

  ### Workspaces
  # Switch to workspace
  "${mod}+a" = "workspace 1:a";
  "${mod}+s" = "workspace 2:s";
  "${mod}+d" = "workspace 3:d";
  "${mod}+f" = "workspace 4:f";
  "${mod}+u" = "workspace 5:u";
  "${mod}+i" = "workspace 6:i";
  "${mod}+o" = "workspace 7:o";
  "${mod}+p" = "workspace 8:p";
  # Move focused container to workspace
  "${mod}+Shift+a" = "move container to workspace 1:a";
  "${mod}+Shift+s" = "move container to workspace 2:s";
  "${mod}+Shift+d" = "move container to workspace 3:d";
  "${mod}+Shift+f" = "move container to workspace 4:f";
  "${mod}+Shift+u" = "move container to workspace 5:u";
  "${mod}+Shift+i" = "move container to workspace 6:i";
  "${mod}+Shift+o" = "move container to workspace 7:o";
  "${mod}+Shift+p" = "move container to workspace 8:p";

  ### Resizing containers
  "${mod}+Left" = "resize shrink width 10px";
  "${mod}+Right" = "resize grow width 10px";
  "${mod}+Down" = "resize shrink height 10px";
  "${mod}+Up" = "resize grow height 10px";

  ### Layout stuff
  "${mod}+c" = "splith";
  "${mod}+v" = "splitv";

  # Switch the current container between different layout styles
  "${mod}+Tab" = "layout toggle stacking split";

  # Make the current focus fullscreen
  F11 = "fullscreen";

  # Toggle the current focus between tiling and floating mode
  "${mod}+y" = "floating toggle";

  # Toggle the current focus to be sticky
  "${mod}+e" = "sticky toggle";

  # Swap focus between the tiling area and the floating area
  "${mod}+Shift+y" = "focus mode_toggle";

  ### Modes
  "${mod}+g" = "mode media";
  "${mod}+Escape" = "mode system";

  ### Scratchpad
  # Move the currently focused window to the scratchpad
  "${mod}+Shift+minus" = "move scratchpad";

  # Show the next scratchpad window or hide the focused scratchpad window.
  # If there are multiple scratchpad windows, this command cycles through them.
  "${mod}+minus" = "scratchpad show";

  ### Apps
  "${mod}+Return" = "exec ${cfg.terminal}";
  "${mod}+t" = "exec ${cfg.menu}";
  "${mod}+b" = "exec ${pkgs.firefox}/bin/firefox";
  "${mod}+m" = "exec ${sway-app-or-workspace} ${pkgs.spotify}/bin/spotify 9:";

  # Mako
  "${mod}+period" = "exec ${makoctl} restore";
  "${mod}+Shift+period" = "exec ${makoctl} menu ${pkgs.wofi}/bin/wofi -d -p 'Choose Action: '";
  "${mod}+Space" = "exec ${makoctl} dismiss";
  "${mod}+Shift+Space" = "exec ${makoctl} dismiss --all";


  # Volume
  # (un)mute output
  XF86AudioMute = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
  # (unmute) microphone
  XF86AudioMicMute = "exec ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";
  # increase output volume
  XF86AudioRaiseVolume = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
  # decrease output volume
  XF86AudioLowerVolume = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";

  # Soundcards
  "${mod}+bracketleft" = "exec ${sway-soundcards} previous";
  "${mod}+bracketright" = "exec ${sway-soundcards} next";

  # Media control
  XF86AudioPlay = "exec ${playerctl} play-pause";
  XF86AudioNext = "exec ${playerctl} next";
  XF86AudioPrev = "exec ${playerctl} previous";

  # Screen capture
  Print = "exec ${sway-capture} -o ${screenshotFolderPath}";
  "${mod}+Home" = Print;
  "${mod}+Print" = "exec ${sway-capture} -o ${screenshotFolderPath} slurped-screenshot";
  "${mod}+Shift+Home" = "${mod}+Print";
  "${mod}+Shift+Print" = "exec ${sway-choose-capture} ${screenshotFolderPath} ${screencastFolderPath}";

  # Backlight
  XF86MonBrightnessUp = "exec ${sway-backlight} inc";
  XF86MonBrightnessDown = "exec ${sway-backlight} dec";
  "${mod}+Shift+Up" = ''exec ${ddcciLight "-A 5"}'';
  "${mod}+Shift+Down" = ''exec ${ddcciLight "-U 5"}'';

  # turn off laptop screen
  F9 = "exec swaymsg output eDP-1 dpms toggle";

  # Inhibit suspend
  F12 = "exec ${pkgs.sway-inhibit}/bin/sway-inhibit";
  XF86AudioMedia = F12;
}

