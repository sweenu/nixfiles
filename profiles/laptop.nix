{ config
, pkgs
, ...
}:

{
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend-then-hibernate";
    lidSwitchDocked = "ignore";
    extraConfig = ''
      HandlePowerKey=lock
      LidSwitchIgnoreInhibited=no
    '';
  };
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  powerManagement.powertop.enable = true;
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  # Reload ddcci module on monitor hotplug
  # services.udev.extraRules =
  #   let
  #     reloadScript = pkgs.writeShellScriptBin "reload-ddcci" ''
  #       ${pkgs.kmod}/bin/modprobe -r ddcci && ${pkgs.kmod}/bin/modprobe ddcci
  #     '';
  #   in
  #   ''
  #     KERNEL=="card0", SUBSYSTEM=="drm", ACTION=="change", RUN+="${reloadScript}/bin/reload-ddcci"
  #   '';

  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [ powertop ];
  };
}
