{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs.python39Packages; [ virtualenv poetry ptpython invoke ];
  };
}
