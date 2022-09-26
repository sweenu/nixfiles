# TODO: make pgcli module
{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    home.packages = [ pkgs.pgcli ];
    xdg.configFile."pgcli/config".source = ./config;
  };
}
