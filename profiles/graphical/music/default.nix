{
  pkgs,
  lib,
  ...
}:
{
  environment.defaultPackages = [
    pkgs.qbz
    pkgs.spotifywm
  ];

  # For spotify connect
  networking.firewall.extraCommands = lib.openTCPPortForLAN 4070;
}
