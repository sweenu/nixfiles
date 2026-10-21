{
  self,
  config,
  pkgs,
  ...
}:

{
  age.secrets.fastmailAppPassword = {
    file = "${self}/secrets/fastmail/app_password.age";
    owner = config.vars.username;
  };

  home-manager.users."${config.vars.username}" =
    let
      homeManagerConfig = config.home-manager.users."${config.vars.username}";
      mailAccountName = "fastmail";
    in
    {
      accounts.email.maildirBasePath = "${homeManagerConfig.xdg.dataHome}/mail";
      accounts.email.accounts."${mailAccountName}" = {
        primary = true;
        flavor = "fastmail.com";
        address = "contact@sweenu.xyz";
        realName = "Sweenu";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.fastmailAppPassword.path}";
        notmuch.enable = true;
        mbsync = {
          enable = true;
          create = "maildir";
        };
      };

      programs = {
        mbsync = {
          enable = true;
        };
        notmuch.enable = true;
      };

      services.mbsync = {
        enable = true;
      };
    };
}
