{ config, ... }:

{
  home-manager.users."${config.vars.username}".services.mako = {
    enable = true;
    settings = {
      font = "${config.vars.defaultFont} 10";
      background-color = "#2D3748";
      progress-color = "source #718096";
      text-color = "#F7FAFC";
      width = 330;
      padding = "15,20";
      margin = "0,10,10,0";
      border-size = 0;
      border-radius = 4;
      max-icon-size = 80;
      format = ''<b>%s</b> [%a]\n%b'';
      default-timeout = 7000;
      ignore-timeout = true;
    };
  };
}
