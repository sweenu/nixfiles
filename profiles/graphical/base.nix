{
  self,
  pkgs,
  config,
  ...
}:

{
  programs = {
    zoom-us.enable = true;
    kdeconnect = {
      enable = true;
      # The phone is reached over the tailnet, and tailscale0 is already a
      # trusted interface, so opening 1714-1764 would only expose the daemon on
      # untrusted Wi-Fi. This is also why avahi keeps the consumer-only publish
      # settings from profiles/core/base.nix: discovery is the customDevices
      # entry below, not an mDNS announcement.
      openFirewall = false;
      # Stop beaconing our device ID and name to 255.255.255.255 on every
      # network we join; the phone is in customDevices instead.
      announceOnBroadcast = false;
    };
  };

  services.gvfs.enable = true;

  environment.defaultPackages = with pkgs; [
    calibre
    imv
    libnotify
    pwvucontrol
    rpi-imager
    vlc
    xdg-utils
  ];

  home-manager.users."${config.vars.username}" = {
    # pixel-9-pro-xl on the tailnet. Must be the IP: kdeconnectd rejects names.
    programs.kdeconnect.customDevices = [ "100.117.165.6" ];

    home.file = {
      ".face".source = "${self}/assets/pp.png";
      "${config.vars.screenshotFolder}/.keep".source = builtins.toFile "keep" "";
      "${config.vars.screencastFolder}/.keep".source = builtins.toFile "keep" "";
      "${config.vars.wallpapersFolder}/.keep".source = builtins.toFile "keep" "";
    };

    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      autostart = {
        enable = true;
      };

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
          # GIO's default-for-uri-scheme lookup only reads this file, not the
          # desktop entry's MimeType=; without it the browser's "open with system
          # default" silently no-ops and claude:// login callbacks never arrive.
          # Claude Desktop can't register itself: mimeapps.list is a store symlink.
          "x-scheme-handler/claude" = [ "com.anthropic.Claude.desktop" ];
          "inode/directory" = [ "dev.duxlabs.files.desktop" ];
          "x-scheme-handler/trash" = [ "dev.duxlabs.files.desktop" ];
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
