# TODO: make glow module
{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    xdg.configFile."glow/glow.yml".source = ./glow.yml;
    home.packages = [ pkgs.glow ];
  };
}
