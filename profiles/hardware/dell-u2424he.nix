{ config, ... }:

{
  home-manager.users."${config.vars.username}" = {
    wayland.windowManager.hyprland.settings.monitor = [ "desc:Dell Inc. DELL U2424HE FF904X3, 1920x1080, 0x0, auto" ];
  };
}
