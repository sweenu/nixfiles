{ config, pkgs, lib, ... }:

{
  programs.sway.enable = true; # sets important config values (e.g. swaylock in pam)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      wofi
      wdisplays
      wf-recorder
      wl-clipboard
      wev
      slurp
      grim
      swappy
      playerctl
      pulseaudio # only for pactl because it's hard to mute or change volume through pw-cli

      # custom scripts
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
        window = {
          border = 1;
          titlebar = false;
          commands = [
            # hack around spotify's wm_class bug: https://github.com/swaywm/sway/issues/3793
            { criteria = { class = "Spotify"; }; command = "move to workspace 9:"; }
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
          { command = "${pkgs.swayidle}/bin/swayidle -w before-sleep '${pkgs.swaylock}/bin/swaylock -f' lock '${pkgs.swaylock}/bin/swaylock -f'"; }
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
            l = "exec swaylock; mode default";
            Return = "mode default";
            Escape = "mode default";
          };
        };
      };
      extraConfig = ''
        titlebar_border_thickness 0
        titlebar_padding 1
      '';
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      wrapperFeatures = { gtk = true; };
      systemdIntegration = false;
    };

    programs.swaylock.settings = import ./swaylock.nix { wallpaper = config.vars.wallpaper; };

    home.file.".xkb/symbols/custom-us".text = ''
      default partial alphanumeric_keys
      xkb_symbols "custom-altgr-intl" {

          include "us(basic)"
          include "level3(ralt_switch)"
          name[Group1]= "English (US, custom algr-intl)";

          key <TLDE> { [ grave,        asciitilde,  egrave,          dead_grave     ] };
          key <AB03> { [ c,            C,           ccedilla,        Ccedilla       ] };
          key <AB08> { [ comma,        less,        dead_cedilla,    guillemotleft  ] };
          key <AB09> { [ period,       greater,     dead_abovedot,   guillemotright ] };
          key <AC01> { [ a,            A,           agrave,          Agrave         ] };
          key <AC02> { [ s,            S,           scedilla,        Scedilla       ] };
          key <AC05> { [ g,            G,           gbreve,          Gbreve         ] };
          key <AC11> { [ apostrophe,   quotedbl,    dead_acute,      dead_diaeresis ] };
          key <AD03> { [ e,            E,           eacute,          Eacute         ] };
          key <AD07> { [ u,            U,           ugrave,          Ugrave         ] };
          key <AD08> { [ i,            I,           idotless,        Iabovedot      ] };
          key <AD09> { [ o,            O,           odiaeresis,      Odiaeresis     ] };
          key <AD11> { [ bracketleft,  braceleft,   oe,              OE             ] };
          key <AD12> { [ bracketright, braceright,  ae,              AE             ] };
          key <AE04> { [ 4,            dollar,      EuroSign                        ] };
          key <AE06> { [ 6,            asciicircum, dead_circumflex                 ] };
      };
    '';

    programs.fish.interactiveShellInit = lib.mkBefore ''
      if test -z $DISPLAY && test (tty) = "/dev/tty1"
          exec sway
      end
    '';
  };
}
