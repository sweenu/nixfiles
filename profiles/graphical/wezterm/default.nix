{ config, ... }:
{
  home-manager.users."${config.vars.username}" = {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./config.lua;
    };
  };
}
