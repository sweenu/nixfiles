{ pkgs, config, ... }:

{
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  boot.kernelModules = [ "ddcci" ];

  fonts.packages = with pkgs; [
    roboto
    font-awesome
    nerd-fonts.dejavu-sans-mono
    twitter-color-emoji
    material-symbols
  ];

  programs = {
    kdeconnect.enable = true;
    thunar.enable = true;
    zoom-us.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      wlr = {
        enable = true;
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
