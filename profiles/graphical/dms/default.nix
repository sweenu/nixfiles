{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.home-manager.users."${config.vars.username}".programs.dank-material-shell;
in
{
  environment.defaultPackages = lib.mkIf cfg.plugins.linuxWallpaperEngine.enable [
    pkgs.linux-wallpaperengine
  ];

  programs.dsearch.enable = true;

  home-manager.users."${config.vars.username}".programs.dank-material-shell = {
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
    enableCalendarEvents = true;
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
      dankPomodoroTimer = {
        enable = true;
        settings = {
          enabled = true;
          autoSetDND = true;
          autoStartBreaks = true;
          autoStartPomodoros = true;
        };
      };

      # Community plugins
      calculator.enable = true;
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
}
