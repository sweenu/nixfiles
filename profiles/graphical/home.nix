{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      calibre
      imv
      libnotify
      obsidian
      paprefs
      pavucontrol
      signal-desktop
      vlc
      xdg-utils
      zoom-us
    ];

    home.file = {
      "${config.vars.screenshotFolder}/.keep".source = builtins.toFile "keep" "";
      "${config.vars.screencastFolder}/.keep".source = builtins.toFile "keep" "";
    };

    services = {
      blueman-applet.enable = config.services.blueman.enable;
      gammastep = {
        enable = true;
        latitude = 48.8;
        longitude = 2.3;
        temperature = { day = 6500; night = 3200; };
        settings = {
          general = { adjustment-method = "wayland"; fade = 1; };
        };
      };
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };

    xdg = {
      enable = true;
      desktopEntries = {
        img = {
          name = "Image Viewer";
          exec = "${pkgs.imv}/bin/imv %u";
          categories = [ "Application" ];
        };
        pdf = {
          name = "PDF reader";
          exec = "${pkgs.zathura}/bin/zathura %u";
          categories = [ "Application" ];
        };
        text = {
          name = "Text editor";
          exec = "${config.vars.terminalBin} -e kak %u";
          categories = [ "Application" ];
        };
      };
      mime.enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/plain" = [ "text.desktop" ];
          "application/postscript" = [ "pdf.desktop" ];
          "application/pdf" = [ "pdf.desktop" ];
          "image/apng" = [ "img.desktop" ];
          "image/png" = [ "img.desktop" ];
          "image/jpeg" = [ "img.desktop" ];
          "image/gif" = [ "img.desktop" ];
          "image/avif" = [ "img.desktop" ];
          "image/svg+xml" = [ "img.desktop" ];
          "image/webp" = [ "img.desktop" ];
        };
      };
    };
  };

  programs.dconf.enable =
    let cfg = config.home-manager.users."${config.vars.username}";
    in cfg.services.blueman-applet.enable || cfg.gtk.enable;
}
