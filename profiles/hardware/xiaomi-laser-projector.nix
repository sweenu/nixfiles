{ config, pkgs, ... }:

let
  limitedRangeIcc = pkgs.runCommand "limited-range.icc" { } ''
    ${pkgs.python3}/bin/python3 -I ${../../pkgs/limited-range-icc.py} > $out
  '';
in
{
  # The projector reads our full-range RGB as limited (16-235), crushing blacks
  # and triggering its dark-scene boost. Layout comes from shikane; this only
  # adds the ICC.
  home-manager.users."${config.vars.username}".wayland.windowManager.hyprland.settings.monitor = [
    {
      output = "desc:FMX Laser Proj 0x00000001";
      icc = "${limitedRangeIcc}";
    }
  ];
}
