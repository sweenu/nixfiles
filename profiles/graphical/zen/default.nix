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
            "browser.urlbar.resultMenu.keyboardAccessible" = true;
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
