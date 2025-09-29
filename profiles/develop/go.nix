{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.go = {
    enable = true;
    env.GOPATH = "${config.vars.home}/.go";
  };
}
