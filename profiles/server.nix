{ config, ... }:

{
  imports = [ ./core/tailscale.nix ];

  environment.variables.BROWSER = "echo";

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
    };
    optimise.automatic = true;
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = false;
  };

  programs.mosh.enable = true;

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      dnsovertls = "opportunistic";
      fallbackDns = config.vars.dnsResolvers;
    };
    tailscale.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];

  # Server optimization
  documentation.enable = false;
  fonts.fontconfig.enable = false;
  environment.stub-ld.enable = false;

  # Taken from: https://github.com/nix-community/srvos/blob/b3af8aed091d85e180a861695f2d57b3b2d24ba1/nixos/server/default.nix#L89
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
