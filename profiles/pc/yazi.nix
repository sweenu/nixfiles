{ config, ... }:
{
  home-manager.users."${config.vars.username}" = {
    programs.yazi = {
      enable = true;
    };
  };
}
