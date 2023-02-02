{ config, pkgs, lib, ... }:

{
  nixpkgs.config.firefox = {
    enableTridactylNative = true;
    speechSynthesisSupport = true;
  };

  home-manager.users."${config.vars.username}" = {
    programs.firefox = {
      enable = true;
      profiles."${config.vars.username}".settings = {
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.uidensity" = 2;
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DBUS_REMOTE = "1";
    };

    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "application/x-extension-htm" = [ "firefox.desktop" ];
      "application/x-extension-html" = [ "firefox.desktop" ];
      "application/x-extension-shtml" = [ "firefox.desktop" ];
      "application/xhtml+xml" = [ "firefox.desktop" ];
      "application/x-extension-xhtml" = [ "firefox.desktop" ];
      "application/x-extension-xht" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/chrome" = [ "firefox.desktop" ];
    };

    # Tridactyl
    xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
    xdg.configFile."tridactyl/themes/base16-oceanicnext.css".source = ./tridactyl_style.css;
  };
}
