{ config, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
  };

  documentation.dev.enable = true;

  environment.defaultPackages = with pkgs; [
    bitwarden
    brightnessctl
    comma
    devenv
    ffmpeg
    simple-scan
    spotifywm
    ethtool
    gitui
    manix
    nix-output-monitor
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
    gnome.gnome-keyring.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        hplip
      ];
    };
    ollama.enable = true;
  };

  security.polkit.enable = true;
  security.pam.services.login.fprintAuth = false;
  security.pam.services.login.enableGnomeKeyring = true;

  programs = {
    gnupg.agent.enable = true;
  };

  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      bitwarden-cli
      gpg-tui
      tmate
      you-get
      yt-dlp
    ];

    programs = {
      keychain = {
        enable = true;
        keys = [ "id_ed25519" ];
      };
      zathura = {
        enable = true;
        options = {
          selection-clipboard = "clipboard";
        };
      };
      glow = {
        enable = true;
        settings = {
          style = "auto";
          local = false;
          width = 100;
          pager = true;
        };
      };
      git.package = pkgs.gitFull;
    };

    manual.json.enable = true; # To use with manix

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
