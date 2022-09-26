{ pkgs, suites, ... }:
{
  imports = suites.base;

  boot.loader.systemd-boot.enable = true;

  environment.defaultPackages = with pkgs; [
    nvme-cli
    parted
  ];

  networking.wireless.enable = false;

  # Required, but will be overridden in the resulting installer ISO.
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };
}
