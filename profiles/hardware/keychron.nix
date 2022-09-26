{ config, ... }:

{
  boot.extraModprobeConfig = ''
    # fix the F* keys on the Keychron K6
    options hid_apple fnmode=0
  '';
  home-manager.users."${config.vars.username}" = {
    wayland.windowManager.sway.config.input = let k6Conf = {
      xkb_layout = "custom-us-keychron";
      xkb_options = "caps:escape";
      repeat_delay = "200";
      repeat_rate = "30";
    }; in
      {
        "1452:591:Keychron_K6_Keyboard" = k6Conf;
        "1452:591:Keychron_Keychron_K6" = k6Conf;
        "1452:591:Keychron_K6" = k6Conf;
      };

    home.file.".xkb/symbols/custom-us-keychron".text = ''
      default partial alphanumeric_keys
      xkb_symbols "custom-altgr-intl-keychron" {
          include "custom-us(custom-altgr-intl)"
          name[Group1]= "English (US, custom algr-intl-keychron)";

          key <ESC> { [ grave, asciitilde, dead_grave, dead_tilde ] };
      };
    '';
  };
}
