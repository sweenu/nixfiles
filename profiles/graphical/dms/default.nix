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
    enable = false;
    compositor.name = "hyprland";
    # Copy the user's DMS theme/settings into the greeter so it matches.
    configHome = config.users.users."${username}".home;
    logs.save = true;
  };

  home-manager.users."${username}" = {
    home.packages = [
      # For the Claude Code Usage plugin's helper script.
      pkgs.jq
      pkgs.curl
      # `dms-settings diff` / `dms-settings dump` to persist live GUI tweaks.
      pkgs.dms-settings
    ];

    # Like settings.json, this is a read-only store symlink DMS can't write to,
    # so GUI plugin tweaks stay in memory. `dms-settings dump-plugins` persists them.
    xdg.configFile."DankMaterialShell/plugin_settings.json".source = ./plugin_settings.json;

    programs.dank-calendar = {
      enable = true;
      systemd.enable = true;
      settings = {
        allDayReminderDaysBefore = 0;
        allDayReminderTime = "09:00";
        allDayReminders = false;
        closeBehavior = "quit";
        colorSource = "auto";
        coreHoursEnabled = false;
        coreHoursEnd = 17;
        coreHoursStart = 9;
        customThemeFile = "";
        defaultEventDurationMinutes = 30;
        defaultReminderMinutes = 10;
        firstDayOfWeek = 1;
        lastView = "week";
        monthEventTitleLines = 1;
        monthShowAllEvents = false;
        notificationSounds = false;
        presetTheme = "purple";
        reminderPersist = false;
        remindersEnabled = false;
        showTasks = true;
        showTrayIcon = false;
        showWeekNumbers = false;
        sidebarCollapsed = false;
        sidebarWidth = 240;
        snoozeMinutes = 5;
        syncIntervalMinutes = 10;
        themeMode = "light";
        timeFormat = "24h";
        use24HourClock = true;
        weekEventTitleLines = 1;
      };
    };

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      # The live settings.json is a read-only store symlink, so DMS treats
      # itself as read-only and keeps GUI edits in memory only (never persisted).
      # That's intentional: this raw JSON is the source of truth and GUI tweaks
      # are ephemeral scratch. Run `dms-settings dump` to write the live state
      # into this file (review with `git diff`), or `dms-settings diff` to preview.
      settings = lib.importJSON ./settings.json;

      enableSystemMonitoring = true;
      enableVPN = false;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      # Calendar is provided by dankcalendar (dcal) instead of khal.
      enableCalendarEvents = false;
      enableClipboardPaste = true;

      # These enable flags only install each plugin's code. Their runtime
      # settings (incl. the effective enabled state DMS reads) live in the
      # plugin_settings.json owned below.
      managePluginSettings = false;
      plugins = {
        # Official plugins
        dankActions.enable = true;
        dankBatteryAlerts.enable = true;
        dankKDEConnect.enable = true;
        dankPomodoroTimer.enable = false;

        # Community plugins
        calculator.enable = true;
        # nderscore/dms-plugins, packaged in the dms-plugin-registry.
        hyprlandSubmapIndicator.enable = true;
        claudeCodeUsage.enable = true;
        emojiLauncher.enable = true;
        powerUsagePlugin.enable = true;
        voxtype.enable = false;
        linuxWallpaperEngine.enable = false;
      };
    };
  };
}
