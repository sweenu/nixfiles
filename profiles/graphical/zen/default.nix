{
  config,
  pkgs,
  ...
}:

{
  home-manager.users."${config.vars.username}" = {
    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
      ];
      profiles.Sweenu = {
        isDefault = true;
        keyboardShortcuts =
          let
            alt = key: {
              inherit key;
              modifiers.alt = true;
            };
            accel = key: {
              inherit key;
              modifiers.accel = true;
            };
            accelAlt = key: {
              inherit key;
              modifiers = {
                accel = true;
                alt = true;
              };
            };
            bind = id: binding: binding // { inherit id; };
            unbind = id: {
              inherit id;
              disabled = true;
            };
          in
          [
            (bind "zen-workspace-forward" (alt "l"))
            (bind "zen-workspace-backward" (alt "h"))
            (bind "zen-compact-mode-toggle" (alt "s"))
            (bind "zen-toggle-sidebar" (alt "b"))
            (bind "zen-glance-expand" (alt "e"))
            (bind "focusURLBar" (alt "o"))
            (bind "key_newNavigatorTab" (accelAlt "o"))
            (bind "zen-new-unsynced-window" (accelAlt "n"))
            (bind "addBookmarkAsKb" (accel "b"))
            (bind "key_openDownloads" (accel "d"))
            (bind "key_openAddons" {
              key = "a";
              modifiers = {
                accel = true;
                shift = true;
              };
            })
            (bind "key_findAgain" { key = "n"; })
            (bind "key_findPrevious" { key = "p"; })
          ]
          ++ map unbind [
            "key_selectTab1"
            "key_selectTab2"
            "key_selectTab3"
            "key_selectTab4"
            "key_selectTab5"
            "key_selectTab6"
            "key_selectTab7"
            "key_selectTab8"
            "key_selectLastTab"
            "key_restoreLastClosedTabOrWindowOrSession"
            "viewBookmarksToolbarKb"
            "viewBookmarksSidebarKb"
            "goHome"
            "goBackKb"
            "goBackKb2"
            "goForwardKb"
            "goForwardKb2"
            "key_newNavigator"
            "zen-compact-mode-show-sidebar"
            "zen-copy-url"
          ];
      };
      policies =
        let
          mkLockedAttrs = builtins.mapAttrs (
            _: value: {
              Value = value;
              Status = "locked";
            }
          );
        in
        {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableMasterPasswordCreation = true;
          DisableSetDesktopBackground = true;
          DisablePrivateBrowsing = true;
          DisplayBookmarksToolbar = "never";
          DontCheckDefaultBrowser = true;
          DownloadDirectory = config.vars.downloadFolder;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
          SearchEngines.Default = "duckduckgo";
          SkipTermsOfUse = true;
          Preferences = {
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.insertRelatedAfterCurrent" = false;
            "browser.tabs.unloadOnLowMemory" = true;
            "browser.urlbar.resultMenu.keyboardAccessible" = true;
            "intl.regional_prefs.use_os_locales" = true;
            "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
            "zen.view.experimental-no-window-controls" = true;
          };
        };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DBUS_REMOTE = "1";
    };

    # Tridactyl
    xdg.configFile."tridactyl/tridactylrc".source = pkgs.replaceVars ./tridactylrc {
      inherit (config.vars) terminalBin domainName tailnetName;
      editor = config.environment.variables.EDITOR;
    };
    xdg.configFile."tridactyl/themes/zen.css".source = ./tridactyl_style.css;
  };
}
