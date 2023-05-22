{ self, config, pkgs, ... }:

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
    wallpaper = "${self}/assets/wallpaper.jpg";
    defaultFont = "Roboto";
    defaultMonoFont = "DejaVuSansM Nerd Font";

    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";

    timezone = "Europe/Paris";

    # najdorf
    domainName = "sweenu.xyz";
    smtpUsername = "contact@sweenu.xyz";
    smtpHost = "smtp.fastmail.com";
    smtpPort = 465;

    # grunfeld
    grunfeldIPv4 = "192.168.0.24";
  };
}
