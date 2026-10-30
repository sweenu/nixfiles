{
  self,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  username = config.vars.username;
  hmCfg = config.home-manager.users."${username}";
  cfg = hmCfg.programs.dank-material-shell;

  dankVaultPatched =
    (import "${inputs.dms-plugin-registry}/nix/default.nix" {
      inherit pkgs;
    }).dankVault.overrideAttrs
      (_: {
        postFixup = ''
          substituteInPlace $out/DankVault.qml \
            --replace-fail "wl-copy --paste-once --sensitive" "wl-copy --sensitive"
        '';
      });
in
{
  imports = [ inputs.dms-greeter.nixosModules.default ];

  age.secrets.hassToken = {
    file = "${self}/secrets/dms/hass_token.age";
    owner = username;
  };

  environment.defaultPackages = lib.mkIf cfg.plugins.linuxWallpaperEngine.enable [
    pkgs.linux-wallpaperengine
  ];

  programs.gpu-screen-recorder.enable = cfg.plugins.quickCapture.enable;

  programs.dux-search = {
    enable = true;
    # Only run in a real graphical session, not the greeter's (its home is
    # /var/empty, where dux-search can't write its index and crash-loops).
    systemd.target = "graphical-session.target";
  };

  # Phone Connect plugin talks to the KDE Connect daemon over D-Bus.
  programs.kdeconnect.enable = true;

  programs.dms-greeter = {
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
      # homeAssistantMonitor dep; the registry module installs sources only.
      pkgs.kdePackages.qtwebsockets
      # quickCapture: WebP/JPEG export and OCR/QR cropping, PDF export, the OCR
      # text scanner and the QR scanner, in that order.
      pkgs.imagemagick
      pkgs.img2pdf
      pkgs.tesseract
      pkgs.zbar
    ];

    # Like settings.json, this is a read-only store symlink DMS can't write to,
    # so GUI plugin tweaks stay in memory. `dms-settings dump-plugins` persists them.
    xdg.configFile."dms/plugin_settings.json".source = ./plugin_settings.json;

    # Their own file watchers cannot see home-manager swapping a symlink.
    systemd.user.services = {
      dms.Unit.X-Restart-Triggers = [
        "${hmCfg.xdg.configFile."dms/settings.json".source}"
        "${hmCfg.xdg.configFile."dms/plugin_settings.json".source}"
      ];
      dcal.Unit.X-Restart-Triggers = [
        "${hmCfg.xdg.configFile."dankcal/ui-settings.json".source}"
      ];
    };

    programs.dank-calendar = {
      enable = true;
      systemd.enable = true;
      settings = {
        allDayReminderDaysBefore = 0;
        allDayReminderTime = "09:00";
        allDayReminders = false;
        closeBehavior = "minimize";
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
      systemd.enable = true;

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

      managePluginSettings = false;
      plugins = {
        # Official plugins
        dankActions.enable = true;
        dankKDEConnect.enable = true;
        dankPomodoroTimer.enable = false;

        # Community plugins
        calculator.enable = true;
        homeAssistantMonitor.enable = true;
        hyprlandSubmapIndicator.enable = true;
        claudeCodeUsage.enable = true;
        emojiLauncher.enable = true;
        powerUsagePlugin.enable = true;
        voxtype.enable = true;
        linuxWallpaperEngine.enable = false;
        quickCapture.enable = true;
        dankVault = {
          enable = true;
          src = lib.mkForce dankVaultPatched;
        };
        dankscale.enable = true;

        # Own plugins
        bibleVerse = {
          enable = true;
          src = inputs.dux-bible-verse;
        };
      };
    };
  };
}
