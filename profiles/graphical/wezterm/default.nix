{ config, pkgs, ... }:
{
  home-manager.users."${config.vars.username}" =
    let
      tablineRepo = pkgs.fetchFromGitHub {
        owner = "michaelbrusegard";
        repo = "tabline.wez";
        rev = "v1.6.0";
        sha256 = "sha256-1/lA0wjkvpIRauuhDhaV3gzCFSql+PH39/Kpwzrbk54=";
      };
    in
    {
      xdg.configFile."wezterm/tabline".source = "${tablineRepo}/plugin";

      programs.wezterm = {
        enable = true;
        extraConfig = builtins.readFile ./config.lua;
      };
    };
}
