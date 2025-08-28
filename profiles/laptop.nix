{ config
, pkgs
, ...
}:

{
  services.logind = {
    settings.Login = {
      HandlePowerKey = "lock";
      LidSwitchIgnoreInhibited = "no";
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
      HandleLidSwitchDocked = "ignore";
    };
  };
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  powerManagement.powertop.enable = true;
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [ powertop ];
    wayland.windowManager.hyprland.settings.workspace = [ "r[5-20], monitor:eDP-1" ];
  };
}
