{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.go = {
    enable = true;
    goPath = ".go";
  };
}
