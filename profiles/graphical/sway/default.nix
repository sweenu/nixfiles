{ config, pkgs, ... }:

{
  programs.sway.enable = true; # sets important config values (e.g. swaylock in pam)
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      sway-soundcards
      sway-app-or-workspace
      sway-inhibit
      sway-backlight
      sway-capture
      sway-choose-capture
    ];

    wayland.windowManager.sway = {
      enable = true;
      config = {
        colors.focused = { border = "#ffffff"; background = "#ffffff"; text = "#ffffff"; indicator = "#ffffff"; childBorder = "#ffffff"; };
        focus.newWindow = "none";
        gaps.inner = 20;
        fonts = { names = [ config.vars.defaultFont ]; size = 0.1; };
        bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];
        floating = {
          titlebar = false;
          criteria = [{ app_id = "zoom"; }];
          border = 1;
        };
        assigns = { "9:" = [{ title = "Spotify"; }]; };
        window = {
          border = 1;
          titlebar = false;
          commands = [
            {
              criteria = { title = "^[Pp]icture[- ]in[- ][Pp]icture"; };
              command = ''floating enable; \
                sticky enable; \
                resize set width 852 height 480'';
            }
            {
              criteria = { title = "^Signal$"; };
              command = ''focus; \
                floating enable; \
                resize set width 647 height 490; \
                move position center; \
                move scratchpad; \
                scratchpad show'';
            }
            { criteria = { title = "Firefox . Sharing Indicator"; }; command = "kill"; }
            {
              criteria = { app_id = "zoom"; title = "^zoom$"; };
              command = "border none; floating enable";
            }
          ];
        };
        workspaceOutputAssign = [
          { output = "*"; workspace = "1:a"; }
          { output = "*"; workspace = "2:s"; }
          { output = "*"; workspace = "3:d"; }
          { output = "*"; workspace = "4:f"; }
          { output = "*"; workspace = "5:u"; }
          { output = "*"; workspace = "6:i"; }
          { output = "*"; workspace = "7:o"; }
          { output = "*"; workspace = "8:p"; }
          { output = "*"; workspace = "9:"; }
        ];
        output = {
          "*" = { bg = "${config.vars.wallpaper} fill"; };
        };
        input = {
          "type:touchpad" = {
            dwt = "enabled";
            tap = "enabled";
            natural_scroll = "enabled";
          };
          "type:keyboard" = {
            xkb_layout = "custom-us";
            xkb_options = "caps:escape";
            repeat_delay = "200";
            repeat_rate = "30";
          };
        };
        startup = [
          { command = "${pkgs.swayidle}/bin/swayidle -w before-sleep '${pkgs.swaylock-fprintd}/bin/swaylock -f' lock '${pkgs.swaylock-fprintd}/bin/swaylock -f'"; }
          { command = "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"; }
          { command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"; }
          { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        ];
        modifier = "Mod4";
        terminal = "${config.vars.terminalBin}";
        menu = "${pkgs.wofi}/bin/wofi -S drun -I -i -a -p Apps 'swaymsg exec -- {cmd}'";
        keybindings = import ./keybindings.nix { inherit config pkgs; };
        modes = {
          media = let playerctl = "${pkgs.playerctl}/bin/playerctl"; in
            {
              Space = "exec ${playerctl} play-pause -p 'spotify,%any'; mode default";
              n = "exec ${playerctl} next -p 'spotify,%any'; mode default";
              p = "exec ${playerctl} previous -p 'spotify,%any'; mode default";
              Return = "mode default";
              Escape = "mode default";
            };
          system = {
            r = "exec reboot";
            s = "exec shutdown now";
            p = "exec systemctl suspend-then-hibernate; mode default";
            l = "exec ${pkgs.swaylock-fprintd}/bin/swaylock; mode default";
            Return = "mode default";
            Escape = "mode default";
          };
        };
      };
      extraConfig = ''
        titlebar_border_thickness 0
        titlebar_padding 1
      '';
      wrapperFeatures = { gtk = true; };
      systemd.enable = false;
    };
  };
}
