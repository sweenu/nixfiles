{ config, ... }:

{
  home-manager.users."${config.vars.username}".services.mako = {
    enable = true;
    font = "DejaVu Sans Mono Nerd Font Complete 10";
    backgroundColor = "#2D3748";
    progressColor = "source #718096";
    textColor = "#F7FAFC";
    width = 330;
    padding = "15,20";
    margin = "0,10,10,0";
    borderSize = 0;
    borderRadius = 4;
    maxIconSize = 80;
    format = ''<b>%s</b> [%a]\n%b'';
    defaultTimeout = 7000;
    ignoreTimeout = true;
  };
}
