{ config, pkgs, ... }:
{
  users.users."${config.vars.username}".extraGroups = pkgs.lib.mapAttrsToList (
    _: client: client.user.group
  ) config.services.netbird.clients;

  services.netbird.clients.efcc = {
    port = 51820;
    ui.enable = true;
  };
}
