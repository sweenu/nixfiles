{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  username = config.vars.username;
  cfg = config.home-manager.users."${username}".programs.dank-material-shell;
in
{
  imports = [ inputs.dms.nixosModules.greeter ];

  environment.defaultPackages = lib.mkIf cfg.plugins.linuxWallpaperEngine.enable [
    pkgs.linux-wallpaperengine
  ];

  programs.dsearch = {
    enable = true;
    # Only run in a real graphical session, not the greeter's (its home is
    # /var/empty, where dsearch can't write its index and crash-loops).
    systemd.target = "graphical-session.target";
  };

  # Phone Connect plugin talks to the KDE Connect daemon over D-Bus.
  programs.kdeconnect.enable = true;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    # Copy the user's DMS theme/settings into the greeter so it matches.
    configHome = config.users.users."${username}".home;
    logs.save = true;
  };

  home-manager.users."${username}" = {
    # Provided for the Claude Code Usage plugin's helper script.
    home.packages = [
      pkgs.jq
      pkgs.curl
    ];

    programs.dank-calendar = {
      enable = true;
      systemd.enable = true;
    };

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      settings = import ./settings.nix;

      enableSystemMonitoring = true;
      enableVPN = false;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      # Calendar is provided by dankcalendar (dcal) instead of khal.
      enableCalendarEvents = false;
      enableClipboardPaste = true;

      plugins = {
        # Official plugins
        dankActions.enable = true;
        dankBatteryAlerts = {
          enable = true;
          settings = {
            criticalThreshold = 10;
          };
        };
        dankKDEConnect.enable = true;
        dankPomodoroTimer = {
          enable = false;
          settings = {
            enabled = true;
            autoSetDND = true;
            autoStartBreaks = true;
            autoStartPomodoros = true;
          };
        };

        # Community plugins
        calculator.enable = true;
        claudeCodeUsage.enable = true;
        emojiLauncher = {
          enable = true;
          settings = {
            trigger = ":";
          };
        };
        powerUsagePlugin.enable = true;
        voxtype.enable = false;
        linuxWallpaperEngine.enable = false;
      };
    };
  };
}
