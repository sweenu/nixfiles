{ config, ... }:

{
  home-manager.users."${config.vars.username}" = {
    wayland.windowManager.hyprland.settings = let monitorDescription = "Dell Inc. DELL U2424HE FF904X3"; in {
      monitor = [ "desc:${monitorDescription}, 1920x1080, auto-left, 1" ];
      workspace = [ "r[1-4], monitor:desc:${monitorDescription}" ];
    };
  };
}
