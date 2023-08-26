{ config, pkgs, ... }:

{
  # boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  # boot.kernelModules = [ "ddcci" ];

  fonts.packages = with pkgs; [
    roboto
    font-awesome
    # only install those fonts from nerdfonts
    (nerdfonts.override {
      fonts = [
        "DejaVuSansMono"
      ];
    })
    twitter-color-emoji
  ];

  programs.light.enable = true;
  programs.kdeconnect.enable = true;

  services.blueman.enable = config.hardware.bluetooth.enable;

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  };
}
