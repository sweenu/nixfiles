{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    languagePacks = [
      "en-US"
      "fr"
    ];
    preferences = {
      "services.sync.prefs.sync.browser.uiCustomization.state" = true;
      "browser.shell.checkDefaultBrowser" = false;
      "browser.aboutConfig.showWarning" = false;
      "browser.uidensity" = 2;
    };
    nativeMessagingHosts.packages = with pkgs; [
      tridactyl-native
      vdhcoapp
    ];
    wrapperConfig = {
      speechSynthesisSupport = true;
    };
  };
}
