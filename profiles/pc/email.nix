{ self
, config
, pkgs
, lib
, ...
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
        realName = "Bruno Inec";
        passwordCommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.fastmailAppPassword.path}";
        notmuch.enable = true;
        mbsync = {
          enable = true;
          create = "maildir";
        };
        himalaya = {
          enable = true;
          settings = {
            backend.type = "maildir";
            backend.root-dir = homeManagerConfig.accounts.email.accounts."${mailAccountName}".maildir.absPath;
          };
        };
      };

      programs = {
        himalaya = {
          enable = true;
          settings = {
            downloads-dir = "${config.vars.home}/${config.vars.downloadFolder}";
          };
        };
        mbsync = {
          enable = true;
        };
        notmuch.enable = true;
      };

      services.mbsync = {
        enable = true;
      };

      home.packages = with pkgs; [
        (writeShellScriptBin "himalaya-tui" ''
          ${skim}/bin/sk -c '${himalaya}/bin/himalaya envelopes list -s 200' \
            --preview "${himalaya}/bin/himalaya message read {1} -t html | \
            ${w3m}/bin/w3m -T text/html" \
            --bind 'space:execute(${himalaya}/bin/himalaya message reply {1})' \
            --reverse --header-lines=2 --ansi
        '')
      ];
    };
}
