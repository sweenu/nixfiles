{ config
, pkgs
, lib
, ...
}:

let palette = config.home-manager.users."${config.vars.username}".colorScheme.palette; in
{
  environment.defaultPackages = with pkgs; [
    app2unit
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
    hyprpicker
    # Custom scripts
    soundcards
    backlight
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = false;
  };

  home-manager.users."${config.vars.username}" = {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "caelestia shell lock lock";
        };
        listener = [
          {
            timeout = 900; # 15 minutes
            on-timeout = "loginctl lock-session";
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

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = false;
          new_window_takes_over_fullscreen = 1;
          exit_window_retains_fullscreen = true;
        };
        binds = {
          movefocus_cycles_fullscreen = true;
          allow_pin_fullscreen = true; # necessary for fullscreening Picture-in-Picture
        };
        xwayland = {
          enabled = config.programs.hyprland.xwayland.enable;
          force_zero_scaling = true;
        };

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
          gaps_out = 40;
          gaps_workspaces = 20;
          border_size = 1;
          "col.active_border" = "rgba(ffffffff)";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        # Decoration settings
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            xray = false;
            special = false;
            ignore_opacity = true; # Allows opacity blurring
            new_optimizations = true;
            popups = true;
            input_methods = true;
            size = 8;
            passes = 2;
          };

          shadow = {
            enabled = true;
            range = 20;
            render_power = 3;
          };
        };

        # Animation settings
        animations.enabled = true;
        animation = [
          "layersIn, 1, 5, emphasizedDecel, slide"
          "layersOut, 1, 4, emphasizedAccel, slide"
          "fadeLayers, 1, 5, standard"

          "windowsIn, 1, 5, emphasizedDecel"
          "windowsOut, 1, 3, emphasizedAccel"
          "windowsMove, 1, 6, standard"
          "workspaces, 1, 5, standard"

          "specialWorkspace, 1, 4, specialWorkSwitch, slidefadevert 15%"

          "fade, 1, 6, standard"
          "fadeDim, 1, 6, standard"
          "border, 1, 6, standard"
        ];

        # Animation curves
        bezier = [
          "specialWorkSwitch, 0.05, 0.7, 0.1, 1"
          "emphasizedAccel, 0.3, 0, 0.8, 0.15"
          "emphasizedDecel, 0.05, 0.7, 0.1, 1"
          "standard, 0.2, 0, 0, 1"
        ];

        # Layout settings
        dwindle = {
          pseudotile = true;
          force_split = 2;
          preserve_split = true;
        };

        master = {
          smart_resizing = false;
        };

        workspace = [
          "1, defaultName:a, persistent:true, default:true"
          "2, defaultName:s, persistent:true"
          "3, defaultName:d, persistent:true"
          "4, defaultName:f, persistent:true"
          "5, defaultName:u, persistent:true"
          "6, defaultName:i, persistent:true"
          "7, defaultName:o, persistent:true"
          "8, defaultName:p, persistent:true"
          "w[tv1]s[false], gapsout:20"
          "f[1]s[false], gapsout:20"
          "special:signal, on-created-empty:app2unit -- ${pkgs.signal-desktop}/bin/signal-desktop"
          "special:spotify, on-created-empty:app2unit -- spotify"
        ];

        # Window rules
        windowrule = [
          "bordercolor rgb(${palette.base0E}), fullscreen:1"
        ] ++ import ./windowrules.nix;

        # Layer rules
        layerrule = [
          "animation fade, hyprpicker" # Colour picker out animation
          "animation fade, logout_dialog" # wlogout
          "animation fade, selection" # slurp
          "animation fade, wayfreeze"

          # Fuzzel
          "animation popin 80%, launcher"
          "blur, launcher"

          # Shell
          "noanim, caelestia-(border-exclusion|area-picker)"
          "animation fade, caelestia-(drawers|background)"

          "blur, caelestia-drawers"
          "ignorealpha 0.57, caelestia-drawers"
        ];
      } // (import ./keybindings.nix { inherit config pkgs; });

      # Submaps configuration
      extraConfig = ''
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

    systemd.user.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";

      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";

      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      SDL_VIDEODRIVER = "wayland,x11";
      CLUTTER_BACKEND = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
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
      if uwsm check may-start -q
          exec uwsm start hyprland-uwsm.desktop
      end
    '';
  };
}
