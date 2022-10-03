{ config, ... }:

{
  services.tailscale.enable = true;

  networking.firewall = {
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    checkReversePath = "loose"; # for Tailscale
  };
}
