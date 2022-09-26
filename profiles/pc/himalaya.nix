{ config, ... }:

{
  home-manager.users."${config.vars.username}" = {
    programs.himalaya = {
      enable = true;
    };
  };
}
