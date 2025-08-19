{ config, pkgs, ... }:

let
  theme = { name = "Orchis"; package = pkgs.orchis-theme; };
  cursorsTheme = { name = "capitaine-cursors-white"; size = 24; package = pkgs.capitaine-cursors; };
  iconsTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
in
{
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      capitaine-cursors
    ];

    gtk = {
      enable = true;
      iconTheme = {
        package = iconsTheme.package;
        name = iconsTheme.name;
      };
      theme = {
        package = theme.package;
        name = theme.name;
      };
      gtk2.extraConfig = ''
        gtk-cursor-theme-name="${cursorsTheme.name}"
        gtk-cursor-theme-size="${builtins.toString cursorsTheme.size}"
      '';
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-cursor-theme-name = cursorsTheme.name;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-cursor-theme-name = cursorsTheme.name;
      };
    };

    home.file.".icons/default/index.theme".text = ''
      [icon theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=${cursorsTheme.name}
    '';

    # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland#setting-values-in-gsettings
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = theme.name;
        icon-theme = iconsTheme.name;
        cursor-theme = cursorsTheme.name;
        color-scheme = "prefer-dark";
      };
    };
  };
}
