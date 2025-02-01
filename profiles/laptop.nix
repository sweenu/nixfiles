{
  config,
  pkgs,
  lib,
  ...
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

    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
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

    wayland.windowManager.sway.config = {
      startup = [
        {
          command = "systemctl restart --user kanshi";
          always = true;
        }
      ];

      workspaceOutputAssign =
        let
          secondaryOutputs = "DP-1 DP-2 DP-3 DP-4 DP-5 DP-6 DP-7 DP-8 HDMI-A-1 HDMI-A-2 HDMI-A-3 HDMI-A-4";
        in
        lib.mkForce [
          {
            output = secondaryOutputs;
            workspace = "1:a";
          }
          {
            output = secondaryOutputs;
            workspace = "2:s";
          }
          {
            output = secondaryOutputs;
            workspace = "3:d";
          }
          {
            output = secondaryOutputs;
            workspace = "4:f";
          }
          {
            output = "eDP-1";
            workspace = "5:u";
          }
          {
            output = "eDP-1";
            workspace = "6:i";
          }
          {
            output = "eDP-1";
            workspace = "7:o";
          }
          {
            output = "eDP-1";
            workspace = "8:p";
          }
          {
            output = "eDP-1";
            workspace = "9:";
          }
        ];
    };
  };
}
