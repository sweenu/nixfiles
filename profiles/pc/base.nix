{ config, pkgs, ... }:

{
  boot.plymouth = {
    enable = true;
  };

  documentation.dev.enable = true;

  environment.defaultPackages = with pkgs; [
    bitwarden-cli
    bitwarden-desktop
    beeper
    brightnessctl
    comma
    devenv
    ethtool
    ffmpeg
    gitui
    gh
    gpg-tui
    nix-search-tv
    nix-output-monitor
    nix-prefetch-git
    nix-prefetch-github
    nixpkgs-review
    python3Packages.ptpython
    simple-scan
    tealdeer
    tmate
    wol
    you-get
    yt-dlp
  ];

  services = {
    avahi.enable = true;
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
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      dnsovertls = "opportunistic";
      fallbackDns = config.vars.dnsResolvers;
    };
  };

  security.polkit.enable = true;
  security.pam.services.login.fprintAuth = false;
  security.pam.services.login.enableGnomeKeyring = true;

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  boot.enableContainers = true;

  programs = {
    gnupg.agent.enable = true;
    nix-ld = {
      enable = true;
    };
  };

  home-manager.users."${config.vars.username}" = {
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
