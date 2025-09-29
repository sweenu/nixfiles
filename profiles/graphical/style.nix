{ config, pkgs, ... }:

let
  theme = {
    name = "Adwaita";
    package = pkgs.gnome-themes-extra;
  };
  themeQt = {
    name = "adwaita-dark";
    package = pkgs.adwaita-qt;
  };
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
    theme.package
    themeQt.package
    cursorTheme.package
    iconsTheme.package
  ];

  fonts.packages = with pkgs; [
    config.vars.defaultFont.package
    config.vars.defaultMonoFont.package
    font-awesome
    twitter-color-emoji
    material-symbols
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

    gtk = {
      enable = true;
      colorScheme = "dark";
      iconTheme = {
        package = iconsTheme.package;
        name = iconsTheme.name;
      };
      theme = {
        package = theme.package;
        name = "${theme.name}";
      };
      font = {
        package = config.vars.defaultFont.package;
        name = config.vars.defaultFont.name;
        size = 12;
      };
      gtk3 = {
        theme = {
          package = theme.package;
          name = "${theme.name}-dark";
        };
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3"; # https://github.com/caelestia-dots/shell/issues/390
      style = {
        name = themeQt.name;
        package = themeQt.package;
      };
    };
  };
}
