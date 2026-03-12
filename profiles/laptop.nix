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
  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
