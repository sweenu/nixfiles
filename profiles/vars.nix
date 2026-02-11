{
  config,
  pkgs,
  lib,
  ...
}:

{
  vars = rec {
    email = "contact@sweenu.xyz";
    username = "sweenu";
    terminal = "wezterm";
    terminalBin = "${pkgs.wezterm}/bin/wezterm";
    defaultBrowser = "zen-twilight";

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
    wallpapersFolder = "${picturesFolder}/wallpapers";
    defaultFont = {
      name = "Roboto";
      package = pkgs.roboto;
    };
    defaultMonoFont = {
      name = "DejaVuSansM Nerd Font";
      package = pkgs.nerd-fonts.dejavu-sans-mono;
    };

    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";

    timezone = "Europe/Paris";

    dnsResolvers = [
      "9.9.9.9"
      "1.1.1.1"
    ];

    # najdorf
    defaultGateway = "192.168.1.254";
    staticIPWithSubnet = "192.168.1.41/24";
    staticIP = builtins.head (lib.splitString "/" staticIPWithSubnet);
    lanSubnet = "192.168.1.0/24";
    domainName = "sweenu.xyz";
    smtp = {
      user = "contact@sweenu.xyz";
      host = "smtp.fastmail.com";
      port = 465;
    };
  };
}
