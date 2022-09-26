{ pkgs, ... }:

{
  environment.defaultPackages = with pkgs; [ discord lutris ];
  programs.steam.enable = true;
}
