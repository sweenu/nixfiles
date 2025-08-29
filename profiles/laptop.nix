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

  services.udev.extraRules =
    let
      activatePowerSaver = pkgs.writeShellScript "power-save" "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver";
      activatePerformance = pkgs.writeShellScript "performance" "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    in
    ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", RUN+="${activatePowerSaver}"
      SUBSYSTEM=="power_supply", ATTR{status}=="Charging", RUN+="${activatePerformance}"
      SUBSYSTEM=="power_supply", ATTR{status}=="Full", RUN+="${activatePerformance}"
    '';
}
