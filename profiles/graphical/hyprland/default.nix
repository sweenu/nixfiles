{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
  palette = config.home-manager.users."${config.vars.username}".colorScheme.palette;
in
{
  environment.defaultPackages = with pkgs; [
    app2unit
    grim
    slurp
    swappy
    wdisplays
    wev
    wf-recorder
    wl-clipboard
    # Custom scripts
    backlight
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  home-manager.users."${config.vars.username}" = {
    wayland.windowManager.hyprland = {
      enable = true;
      package = config.programs.hyprland.package;
      portalPackage = config.programs.hyprland.portalPackage;
      systemd.variables = [ "--all" ];

      settings = {
        config = {
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = false;
            on_focus_under_fullscreen = 1;
            exit_window_retains_fullscreen = true;
            focus_on_activate = true;
          };
          binds = {
            movefocus_cycles_fullscreen = true;
            allow_pin_fullscreen = true; # necessary for fullscreening Picture-in-Picture
            hide_special_on_workspace_change = true;
          };
          xwayland = {
            enabled = config.programs.hyprland.xwayland.enable;
            force_zero_scaling = true;
          };

          input = {
            kb_layout = "custom-us";
            kb_options = "caps:escape";
            repeat_rate = 30;
            repeat_delay = 200;
            touchpad = {
              natural_scroll = true;
              disable_while_typing = true;
              tap_to_click = true;
            };
          };

          general = {
            gaps_in = 10;
            gaps_out = 40;
            gaps_workspaces = 20;
            border_size = 1;
            col = {
              active_border = "rgba(ffffffff)";
              inactive_border = "rgba(595959aa)";
            };
            layout = "dwindle";
          };

          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              size = 10;
              passes = 4;

              ignore_opacity = true;
              new_optimizations = true;
              xray = false;

              noise = 0.02;
              contrast = 1.1;
              vibrancy = 0.2;
              vibrancy_darkness = 0.3;
            };

            shadow = {
              enabled = true;
              range = 20;
              render_power = 3;
            };
          };

          animations.enabled = true;

          dwindle = {
            force_split = 2;
            preserve_split = true;
          };

          master = {
            smart_resizing = false;
          };
        };

        # Animation curves
        curve = [
          {
            _args = [
              "specialWorkSwitch"
              {
                type = "bezier";
                points = [
                  [
                    0.05
                    0.7
                  ]
                  [
                    0.1
                    1
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "emphasizedAccel"
              {
                type = "bezier";
                points = [
                  [
                    0.3
                    0
                  ]
                  [
                    0.8
                    0.15
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "emphasizedDecel"
              {
                type = "bezier";
                points = [
                  [
                    0.05
                    0.7
                  ]
                  [
                    0.1
                    1
                  ]
                ];
              }
            ];
          }
          {
            _args = [
              "standard"
              {
                type = "bezier";
                points = [
                  [
                    0.2
                    0
                  ]
                  [
                    0
                    1
                  ]
                ];
              }
            ];
          }
        ];

        # Animations
        animation = [
          {
            leaf = "layersIn";
            enabled = true;
            speed = 5;
            bezier = "emphasizedDecel";
            style = "slide";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 4;
            bezier = "emphasizedAccel";
            style = "slide";
          }
          {
            leaf = "fadeLayers";
            enabled = true;
            speed = 5;
            bezier = "standard";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 5;
            bezier = "emphasizedDecel";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 3;
            bezier = "emphasizedAccel";
          }
          {
            leaf = "windowsMove";
            enabled = true;
            speed = 6;
            bezier = "standard";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 5;
            bezier = "standard";
          }
          {
            leaf = "specialWorkspace";
            enabled = true;
            speed = 4;
            bezier = "specialWorkSwitch";
            style = "slidefadevert 15%";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 6;
            bezier = "standard";
          }
          {
            leaf = "fadeDim";
            enabled = true;
            speed = 6;
            bezier = "standard";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 6;
            bezier = "standard";
          }
        ];

        workspace_rule = [
          {
            workspace = "1";
            default_name = "a";
            persistent = true;
            default = true;
          }
          {
            workspace = "2";
            default_name = "s";
            persistent = true;
          }
          {
            workspace = "3";
            default_name = "d";
            persistent = true;
          }
          {
            workspace = "4";
            default_name = "f";
            persistent = true;
          }
          {
            workspace = "5";
            default_name = "u";
            persistent = true;
          }
          {
            workspace = "6";
            default_name = "i";
            persistent = true;
          }
          {
            workspace = "7";
            default_name = "o";
            persistent = true;
          }
          {
            workspace = "8";
            default_name = "p";
            persistent = true;
          }
          {
            workspace = "w[tv1]s[false]";
            gaps_out = 20;
          }
          {
            workspace = "f[1]s[false]";
            gaps_out = 20;
          }
          {
            workspace = "special:communication";
            on_created_empty = "app2unit -- ${pkgs.beeper}/bin/beeper";
          }
          {
            workspace = "special:music";
            on_created_empty = "app2unit -- spotify";
          }
          {
            workspace = "special:claude";
            on_created_empty = "app2unit -- claude-desktop";
          }
        ];

        window_rule = [
          {
            match.fullscreen = true;
            border_color = "rgb(${palette.base0E})";
          }
        ]
        ++ import ./windowrules.nix;

        layer_rule = import ./layoutrules.nix;

        bind = import ./keybindings.nix { inherit lib config pkgs; };
      };

      submaps.window = {
        onDispatch = "reset";
        settings.bind = [
          {
            _args = [
              "p"
              (mkLuaInline "hl.dsp.window.pin()")
            ];
          }
          {
            _args = [
              "f"
              (mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
            ];
          }
          {
            _args = [
              "Return"
              (mkLuaInline "hl.dsp.no_op()")
            ];
          }
          {
            _args = [
              "Escape"
              (mkLuaInline "hl.dsp.no_op()")
            ];
          }
        ];
      };
    };

    systemd.user.sessionVariables = {
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
          exec uwsm start -e -D Hyprland ${config.programs.hyprland.package}/share/wayland-sessions/hyprland.desktop
      end
    '';
  };
}
