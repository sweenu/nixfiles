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
    registry = {
      nixos-unstable = {
        from = {
          type = "indirect";
          id = "nixos-unstable";
        };
        to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          ref = "nixos-unstable";
        };
      };
      nixpkgs-master = {
        from = {
          type = "indirect";
          id = "nixpkgs-master";
        };
        to = {
          type = "github";
          owner = "NixOS";
          repo = "nixpkgs";
          ref = "master";
        };
      };
    };
    settings = {
      extra-experimental-features = "nix-command flakes";
      extra-substituters = [
        "https://attic.${config.vars.tailnetName}/main"
        "https://nix-community.cachix.org"
        "https://deploy-rs.cachix.org"
      ];
      extra-trusted-public-keys = [
        "main:OWXJKAuxiGFPlH/3K65aE5q5T7tkJxZ2DMmKGpUy3Oo="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
      ];
    };
  };

}
