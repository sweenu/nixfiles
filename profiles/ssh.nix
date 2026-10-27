{ config, ... }:

let
  efccAddress = "efcc.thefederation.eu";
in
{
  home-manager.users."${config.vars.username}".programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      najdorf-boot = {
        HostName = config.vars.staticIP;
        User = "root";
        HostKeyAlias = "najdorf-boot";
      };

      efcc = {
        HostName = efccAddress;
        User = "bruno";
      };
      efcc-boot = {
        HostName = efccAddress;
        User = "root";
        HostKeyAlias = "efcc-boot";
      };

      "*" = {
        AddKeysToAgent = "yes";
        IdentitiesOnly = "yes";
      };
    };
  };
}
