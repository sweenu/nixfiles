{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  home-manager.users."${config.vars.username}" = {
    programs.zen-browser = {
      enable = true;
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
          DisplayBookmarksToolbar = "never";
          DontCheckDefaultBrowser = true;
          DownloadDirectory = config.vars.downloadFolder;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
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
          };
        };
    };

    xdg.mimeApps =
      let
        associations = builtins.listToAttrs (
          map
            (name: {
              inherit name;
              value =
                let
                  zen-browser = inputs.zen-browser.packages.${pkgs.system}.twilight;
                in
                zen-browser.meta.desktopFileName;
            })
            [
              "application/x-extension-shtml"
              "application/x-extension-xhtml"
              "application/x-extension-html"
              "application/x-extension-xht"
              "application/x-extension-htm"
              "x-scheme-handler/unknown"
              "x-scheme-handler/mailto"
              "x-scheme-handler/chrome"
              "x-scheme-handler/about"
              "x-scheme-handler/https"
              "x-scheme-handler/http"
              "application/xhtml+xml"
              "application/json"
              "text/plain"
              "text/html"
            ]
        );
      in
      lib.mkIf (lib.strings.hasPrefix "zen" config.vars.defaultBrowser) {
        associations.added = associations;
        defaultApplications = associations;
      };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DBUS_REMOTE = "1";
    };

    # Tridactyl
    xdg.configFile."tridactyl/tridactylrc".source = pkgs.replaceVars ./tridactylrc {
      inherit (config.vars) terminalBin domainName;
      editor = config.environment.variables.EDITOR;
    };
    xdg.configFile."tridactyl/themes/zen.css".source = ./tridactyl_style.css;
  };
}
