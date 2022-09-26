{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".home.packages = [ pkgs.docker-compose ];
}
