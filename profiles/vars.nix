{ config, pkgs, ... }:

{
  vars = rec {
    email = "contact@sweenu.xyz";
    username = "sweenu";
    terminal = "alacritty";
    terminalBin = "${pkgs.alacritty}/bin/alacritty";

    home = "/home/${username}";
    configHome = (builtins.getAttr username config.home-manager.users).xdg.configHome;
    documentsFolder = "documents";
    downloadFolder = "downloads";
    musicFolder = "music";
    picturesFolder = "pictures";
    videosFolder = "videos";
    repositoriesFolder = "repos";
    screenshotFolder = "${picturesFolder}/screenshots";
    screencastFolder = "${videosFolder}/screencasts";
    wallpaper = "${home}/${picturesFolder}/sunshine_through_mountains_wallpaper-2560×1440.jpg";

    # Server
    domainName = "sweenu.xyz";
    smtpUsername = "contact@sweenu.xyz";
    smtpHost = "smtp.fastmail.com";
    smtpPort = 465;
  };
}
