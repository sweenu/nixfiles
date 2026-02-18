{ lib, config, ... }:

{
  hardware = {
    enableAllFirmware = true;
    enableAllHardware = true;
  };

  networking.firewall = {
    enable = lib.mkDefault true;
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
  };

  time.timeZone = lib.mkDefault config.vars.timezone;

  system.stateVersion = "26.05";

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  nix = {
    channel.enable = false;
    settings = {
      extra-experimental-features = "nix-command flakes";
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://sweenu.cachix.org"
        "https://deploy-rs.cachix.org"
        "https://cache.garnix.io"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "sweenu.cachix.org-1:DvQl16NWBp41k5IlxTODTOrIThyGRj8/ekrXxEheBQ0="
        "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
  };

}
