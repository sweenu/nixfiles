{ pkgs, ... }:

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

  environment.defaultPackages = with pkgs; [ powertop ];
}
