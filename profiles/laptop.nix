{ config
, pkgs
, lib
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
  services.auto-cpufreq = {
    enable = true;
  };
  powerManagement.powertop.enable = true;
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  # Reload ddcci module on monitor hotplug
  services.udev.extraRules =
    let
      reloadScript = pkgs.writeShellScriptBin "reload-ddcci" ''
        ${pkgs.kmod}/bin/modprobe -r ddcci && ${pkgs.kmod}/bin/modprobe ddcci
      '';
    in
    ''
      KERNEL=="card0", SUBSYSTEM=="drm", ACTION=="change", RUN+="${reloadScript}/bin/reload-ddcci"
    '';

  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [ powertop ];

    # Battery optimization
    wayland.windowManager.hyprland.settings = {
      decoration = {
        blur.enabled = false;
      };
      misc = {
        disable_autoreload = true;
      };
    };
    services.hyprpaper = {
      settings.ipc = false;
    };

    programs.waybar.settings.mainBar.modules-right = lib.mkForce [
      "tray"
      "network"
      "bluetooth"
      "pulseaudio"
      "backlight"
      "battery"
      "clock"
    ];
  };
}
