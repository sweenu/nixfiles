{
  pkgs,
  lib,
  ...
}:
{
  environment.defaultPackages = [
    pkgs.spotifywm
  ];

  # For spotify connect
  networking.firewall.extraCommands = lib.openTCPPortForLAN 4070;
}
