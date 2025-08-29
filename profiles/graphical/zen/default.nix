{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = with pkgs; [
        tridactyl-native
      ];
    };
  };
}
