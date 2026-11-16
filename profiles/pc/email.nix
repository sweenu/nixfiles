{ config, ... }:

{
  home-manager.users."${config.vars.username}" = {
    accounts.email.accounts.fastmail = {
      primary = true;
      flavor = "fastmail.com";
      address = config.vars.email;
      realName = "Sweenu";
      thunderbird.enable = true;
    };

    programs.thunderbird = {
      enable = true;
      profiles.${config.vars.username}.isDefault = true;
    };
  };
}
