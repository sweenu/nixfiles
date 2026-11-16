{ pkgs, ... }:

{
  environment.defaultPackages = [ pkgs.nod ];

  # AT-SPI bus for computer use; Hyprland owns the special workspace, see graphical/hyprland.
  services.gnome.at-spi2-core.enable = true;
}
