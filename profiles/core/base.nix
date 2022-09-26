{ config, pkgs, lib, ... }:

{
  boot.cleanTmpDir = true;

  environment = {
    # Using anything other than bash seems to not be recommended in Nix
    # binsh = ${pkgs.dash}/bin/dash;
    defaultPackages = with pkgs; [
      bind
      binutils
      curl
      dua
      du-dust
      dnsutils
      entr
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
      nnn
      nix-tree
      pciutils
      psmisc
      procs
      ripgrep
      rsync
      skim
      speedtest-cli
      tailscale
      tmux
      unzip
      usbutils
      uutils-coreutils
      wget2
      whois
      xsv
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
    firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose"; # for Tailscale
    };
    networkmanager.enable = true;
    wireguard.enable = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      sandbox = true;
      trusted-users = [ "root" "@wheel" ];
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
      nssmdns = true;
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
      locate = pkgs.plocate;
      localuser = null;
    };
    openssh.enable = true;
    resolved = {
      extraConfig = ''
        # No need when using Avahi
        MulticastDNS=no
      '';
    };
    tailscale.enable = true;
  };

  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  system.stateVersion = lib.mkDefault "22.11";
}
