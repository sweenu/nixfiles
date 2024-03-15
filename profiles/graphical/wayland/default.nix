{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XDG_CURRENT_DESKTOP = config.vars.compositor;
  };

  home-manager.users."${config.vars.username}" = {
    programs.fish.interactiveShellInit = lib.mkBefore ''
      if test -z $DISPLAY && test (tty) = "/dev/tty1"
          exec ${config.vars.compositor}
      end
    '';

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
    ];

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-fprintd;
      settings = import ./swaylock.nix { wallpaper = config.vars.wallpaper; };
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
  };
}
