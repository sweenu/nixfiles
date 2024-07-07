{ config, ... }:

{
  home-manager.users."${config.vars.username}" = {
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
