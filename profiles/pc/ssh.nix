{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.ssh = {
    extraConfig = ''
      AddKeysToAgent yes
      IdentitiesOnly yes
    '';
  };
}
