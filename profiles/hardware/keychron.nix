{ config, ... }:

let
  layoutName = "custom-us-keychron";
in
{
  boot.extraModprobeConfig = ''
    # fix the F* keys on the Keychron K6
    options hid_apple fnmode=0
  '';

  home-manager.users."${config.vars.username}" = {
    wayland.windowManager.hyprland.settings.device =
      let
        k6Conf = name: {
          name = name;
          kb_layout = layoutName;
          kb_options = "caps:escape";
          repeat_rate = 30;
          repeat_delay = 200;
        };
      in
      [
        (k6Conf "keychron-keychron-k6")
        (k6Conf "keychron-keychron-k6-1")
        (k6Conf "keychron-keychron-k6-2")
      ];

    home.file.".xkb/symbols/${layoutName}".text = ''
      default partial alphanumeric_keys
      xkb_symbols "custom-altgr-intl-keychron" {
          include "custom-us(custom-altgr-intl)"
          name[Group1]= "English (US, custom algr-intl-keychron)";

          key <ESC> { [ grave, asciitilde, dead_grave, dead_tilde ] };
      };
    '';
  };
}
