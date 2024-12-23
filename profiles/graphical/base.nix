{ pkgs, ... }:

{
  # boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  # boot.kernelModules = [ "ddcci" ];

  fonts.packages = with pkgs; [
    roboto
    font-awesome
    nerd-fonts.dejavu-sans-mono
    twitter-color-emoji
  ];

  programs.light.enable = true;
  programs.kdeconnect.enable = true;

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
