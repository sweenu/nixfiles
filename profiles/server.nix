{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.loader = {
    grub.configurationLimit = 5;
    systemd-boot.configurationLimit = 5;
  };

  environment = {
    variables.BROWSER = "echo";
    stub-ld.enable = false;
    systemPackages = with pkgs; [
      kakoune
      gitMinimal
      dnsutils
      ethtool
      curl
      btop
      jq
      tmux
    ];
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
    };
    optimise.automatic = true;
  };

  networking = {
    useDHCP = lib.mkDefault false;
    useNetworkd = true;
    networkmanager.enable = false;
  };

  programs.mosh.enable = true;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    resolved = {
      enable = true;
      settings.Resolve = {
        DNSSEC = "false"; # DNS resolution stops working after a while with `allow-downgrade`
        DNSOverTLS = "opportunistic";
        FallbackDNS = config.vars.dnsResolvers;
        LLMNR = "false"; # Prevent LLMNR poisoning attacks
      };
    };
    tailscale = {
      useRoutingFeatures = "server";
      extraUpFlags = [
        "--ssh"
        "--advertise-exit-node"
      ];
    };
  };

  # Choose to restart manually so that we can deploy without being cut out from the server we deploy to
  systemd.services.tailscaled.restartIfChanged = false;

  # Server optimization
  documentation.enable = false;
  fonts.fontconfig.enable = false;
  programs.command-not-found.enable = false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
}
