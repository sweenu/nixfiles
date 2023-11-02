{ config, pkgs, ... }:

{
  documentation.dev.enable = true;

  environment.defaultPackages = with pkgs; [
    ffmpeg
    simple-scan
    spotifywm
    ethtool
    gitui
    manix
    nixpkgs-review
    python3Packages.ptpython
    tealdeer
    wol
  ];

  services = {
    getty = {
      extraArgs = [ "--skip-login" ];
      loginOptions = "${config.vars.username}";
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint gutenprintBin hplip ];
    };
  };

  security.polkit.enable = true;

  programs.steam.enable = true;

  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      bitwarden-cli
      gpg-tui
      tmate
      viu
      you-get
    ];

    programs = {
      keychain = {
        enable = true;
        keys = [ "id_ed25519" ];
        agents = [ "ssh" ];
      };
      zathura = {
        enable = true;
        options = { selection-clipboard = "clipboard"; };
      };
    };

    services.playerctld.enable = true;

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      documents = "${config.vars.home}/${config.vars.documentsFolder}";
      download = "${config.vars.home}/${config.vars.downloadFolder}";
      music = "${config.vars.home}/${config.vars.musicFolder}";
      pictures = "${config.vars.home}/${config.vars.picturesFolder}";
      templates = "${config.vars.home}/${config.vars.repositoriesFolder}";
      videos = "${config.vars.home}/${config.vars.videosFolder}";
      desktop = "${config.vars.home}";
      publicShare = "${config.vars.home}";
    };
  };
}
