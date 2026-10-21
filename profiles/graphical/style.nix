{ config, pkgs, ... }:

let
  gtkTheme = pkgs.adw-gtk3;
  cursorTheme = {
    name = "capitaine-cursors-white";
    size = 24;
    package = pkgs.capitaine-cursors;
  };
  iconsTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
  homeCfg = config.home-manager.users."${config.vars.username}";
in
{
  environment.systemPackages = [
    gtkTheme
    cursorTheme.package
    iconsTheme.package
  ];

  fonts.packages = with pkgs; [
    config.vars.defaultFont.package
    config.vars.defaultMonoFont.package
    font-awesome
    twitter-color-emoji
    material-symbols
    symbola
  ];

  home-manager.users."${config.vars.username}" = {
    home.pointerCursor = {
      enable = true;
      package = cursorTheme.package;
      name = cursorTheme.name;
      size = cursorTheme.size;
      gtk.enable = true;
      dotIcons.enable = true;
      hyprcursor.enable = homeCfg.wayland.windowManager.hyprland.enable;
      sway.enable = homeCfg.wayland.windowManager.sway.enable;
      x11.enable = false;
    };

    # DMS probes only ~/.local/share/themes, ~/.themes and /usr/share/themes.
    home.file = {
      ".local/share/themes/adw-gtk3".source = "${gtkTheme}/share/themes/adw-gtk3";
      ".local/share/themes/adw-gtk3-dark".source = "${gtkTheme}/share/themes/adw-gtk3-dark";
    };

    # No theme/colorScheme on purpose: DMS owns gtk-theme and color-scheme.
    gtk = {
      enable = true;
      iconTheme = {
        package = iconsTheme.package;
        name = iconsTheme.name;
      };
      font = {
        package = config.vars.defaultFont.package;
        name = config.vars.defaultFont.name;
        size = 12;
      };
    };

    # nixpkgs' qtengine ships the Qt6 plugin only, so Qt5 apps stay unstyled.
    qt = {
      enable = true;
      platformTheme = {
        name = "qtengine";
        package = pkgs.qtengine;
      };
    };
  };
}
