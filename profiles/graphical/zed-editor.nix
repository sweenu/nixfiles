{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.zed-editor = {
    enable = true;
  };
}
