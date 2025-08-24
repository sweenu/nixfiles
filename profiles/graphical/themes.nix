{ config, pkgs, ... }:

let
  theme = { name = "Orchis"; package = pkgs.orchis-theme; };
  cursorTheme = { name = "capitaine-cursors-white"; size = 24; package = pkgs.capitaine-cursors; };
  iconsTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
in
{
  home-manager.users."${config.vars.username}" = {
    home.packages = [
      theme.package
      cursorTheme.package
      iconsTheme.package
    ];

    systemd.user.sessionVariables = {
      XCURSOR_THEME = "${cursorTheme.name}";
      XCURSOR_SIZE = "${builtins.toString cursorTheme.size}";
      HYPRCURSOR_THEME = "${cursorTheme.name}";
      HYPRCURSOR_SIZE = "${builtins.toString cursorTheme.size}";
    };

    gtk = {
      enable = true;
      cursorTheme = {
        package = cursorTheme.package;
        name = cursorTheme.name;
        size = cursorTheme.size;
      };
      iconTheme = {
        package = iconsTheme.package;
        name = iconsTheme.name;
      };
      theme = {
        package = theme.package;
        name = theme.name;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3"; # https://github.com/caelestia-dots/shell/issues/390
    };

    home.file.".icons/default/index.theme".text = ''
      [icon theme]
      Name=Default
      Comment=Default Cursor Theme
      Inherits=${cursorTheme.name}
    '';

    # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland#setting-values-in-gsettings
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = theme.name;
        icon-theme = iconsTheme.name;
        cursor-theme = cursorTheme.name;
        cursor-size = cursorTheme.size;
        color-scheme = "prefer-dark";
      };
    };
  };
}
