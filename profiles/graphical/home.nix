{ self, config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      anki
      calibre
      imv
      libnotify
      obsidian
      pwvucontrol
      signal-desktop
      vlc
      xdg-utils
    ];

    home.file = {
      ".face".source = "${self}/assets/pp.png";
      "${config.vars.screenshotFolder}/.keep".source = builtins.toFile "keep" "";
      "${config.vars.screencastFolder}/.keep".source = builtins.toFile "keep" "";
      "${config.vars.wallpapersFolder}/.keep".source = builtins.toFile "keep" "";
    };

    services = {
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
}
