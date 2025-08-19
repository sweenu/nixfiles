{ config
, pkgs
, lib
, inputs
, ...
}:

{
  programs.hyprland.enable = true;

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
      # Hyprland ecosystem tools
      hypridle
      hyprlock
      hyprpaper
      hyprpicker
      # Custom scripts
      soundcards
      inhibit
      backlight
      capture
      choose-capture
    ];

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [
          "${config.vars.wallpaper}"
        ];
        wallpaper = [
          ",${config.vars.wallpaper}"
        ];
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock";
        };
        listener = [
          {
            timeout = 900; # 15 minutes
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200; # 20 minutes
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    services.hyprsunset = {
      enable = true;
    };

    services.hyprpolkitagent = {
      enable = true;
    };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };
        auth = {
          fingerprint = {
            enabled = true;
          };
        };
        background = [
          {
            path = "${config.vars.wallpaper}";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      systemd.enable = true;

      settings = {
        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          new_window_takes_over_fullscreen = 1;
          exit_window_retains_fullscreen = true;
        };
        binds = {
          movefocus_cycles_fullscreen = true;
        };
        xwayland = {
          force_zero_scaling = true;
        };

        monitor = [ ", preferred, auto-left, auto" ];

        # Input configuration
        input = {
          kb_layout = "custom-us";
          kb_options = "caps:escape";
          repeat_rate = 30;
          repeat_delay = 200;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            tap-to-click = true;
          };
        };

        # General settings
        general = {
          gaps_in = 10;
          gaps_out = 20;
          border_size = 1;
          "col.active_border" = "rgba(ffffffff)";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        # Decoration settings
        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
        };

        # Animation settings
        animations = {
          enabled = false;
        };

        # Layout settings
        dwindle = {
          pseudotile = true;
          force_split = 2;
          preserve_split = true;
        };

        master = {
          smart_resizing = false;
        };

        workspace = let externalMonitors = "{DP-1,DP-2,DP-3,DP-4,HDMI-A-1,HDMI-A-2,HDMI-A-3,HDMI-A-4}"; in [
          "1, defaultName:a, monitor:${externalMonitors}, monitor:default:true"
          "1, defaultName:a, monitor:eDP-1, monitor:default:true" # to have "a" be the default also on the laptop monitor
          "2, defaultName:s, monitor:${externalMonitors}"
          "3, defaultName:d, monitor:${externalMonitors}"
          "4, defaultName:f, monitor:${externalMonitors}"
          "5, defaultName:u, monitor:eDP-1"
          "6, defaultName:i, monitor:eDP-1"
          "7, defaultName:o, monitor:eDP-1"
          "8, defaultName:p, monitor:eDP-1"
          "9, defaultName:, monitor:eDP-1, on-created-empty:${pkgs.spotify}/bin/spotify"
        ];

        # Window rules
        windowrule = [
          # Change border color if in fullscreen:1
          "bordercolor rgb(FDEA6B), fullscreen:1"

          # Picture-in-picture
          "float, title:^[Pp]icture[- ]in[- ][Pp]icture"
          "pin, title:^[Pp]icture[- ]in[- ][Pp]icture"
          "size 852 480, title:^[Pp]icture[- ]in[- ][Pp]icture"

          # Signal
          "float, class:Signal"
          "size 647 490, class:Signal"
          "center, class:Signal"

          # Kill Firefox sharing indicator
          "suppressevent maximize fullscreen, title:Firefox.*Sharing Indicator"
        ];

        # Variables
        "$mod" = "SUPER";
        "$terminal" = "${config.vars.terminalBin}";
        "$menu" = "${pkgs.wofi}/bin/wofi -S drun -I -i -a -p Apps";
      } // (import ./keybindings.nix { inherit config pkgs; });

      # Submaps configuration
      extraConfig = ''
        # System submap
        submap = system
        bind = , r, exec, reboot
        bind = , s, exec, shutdown now
        bind = , p, exec, systemctl suspend-then-hibernate
        bind = , p, submap, reset
        bind = , l, exec, hyprlock
        bind = , l, submap, reset
        bind = , Return, submap, reset
        bind = , Escape, submap, reset
        submap = reset

        # Window submap
        submap = window
        bind =  , p, pin
        bind =  , p, submap, reset
        bind =  , f, togglefloating
        bind =  , f, submap, reset
        bind = , Return, submap, reset
        bind = , Escape, submap, reset
        submap = reset
      '';
    };

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
          exec dbus-run-session Hyprland
      end
    '';
  };
}
