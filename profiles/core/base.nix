{ pkgs, lib, ... }:

{
  systemd.services.NetworkManager-wait-online.enable = false;
  boot.tmp.cleanOnBoot = true;

  environment = {
    # Using anything other than bash seems to not be recommended in Nix
    # binsh = ${pkgs.dash}/bin/dash;
    defaultPackages = with pkgs; [
      bind
      binutils
      curl
      dua
      dust
      dnsutils
      entr
      ethtool
      fd
      file
      gdu
      git
      highlight
      inetutils
      iputils
      jq
      kakoune
      less
      lshw
      moreutils
      nmap
      nvd
      nix-tree
      pciutils
      psmisc
      procs
      ripgrep
      rsync
      skim
      speedtest-cli
      tmux
      gtrash
      unzip
      usbutils
      uutils-coreutils
      wget2
      whois
      yq
      zip
    ];
    variables = {
      EDITOR = "kak";
      VISUAL = "less";
    };
  };

  hardware.enableAllFirmware = true;

  networking = {
    useDHCP = false;
    firewall.enable = true;
  };

  nix = {
    package = pkgs.nixVersions.latest;
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      sandbox = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = true;
      min-free = 536870912;
      keep-outputs = true;
      keep-derivations = true;
      fallback = true;
      warn-dirty = false;
    };
  };

  location.provider = "geoclue2";

  programs = {
    fish.enable = true;
    mosh.enable = true;
    mtr.enable = true;
  };

  security = {
    rtkit.enable = true;
    sudo.extraConfig = "Defaults timestamp_timeout=300";
  };

  services = {
    avahi = {
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        userServices = true;
      };
    };
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 5;
    };
    geoclue2.enable = true;
    locate = {
      enable = true;
      interval = "daily";
      package = pkgs.plocate;
    };
    resolved = {
      extraConfig = ''
        # No need when using Avahi
        MulticastDNS=no
      '';
    };
  };

  systemd.settings.Manager = {
    DefaultLimitNOFILE = 1048576;
  };

  system.stateVersion = lib.mkDefault "24.05";
}
