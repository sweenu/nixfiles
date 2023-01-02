{ config, pkgs, ... }:

{
  # waiting for https://gitlab.com/ddcci-driver-linux/ddcci-driver-linux/-/merge_requests/11 to be merged
  # boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  # boot.kernelModules = [ "ddcci" ];

  fonts.fonts = with pkgs; [
    dejavu_fonts
    font-awesome
    twitter-color-emoji
    (nerdfonts.override { fonts = [ "DejaVuSansMono" ]; })
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
