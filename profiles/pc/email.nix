{ self, config, pkgs, ... }:

{
  age.secrets = {
    fastmailToken = {
      file = "${self}/secrets/fastmail_token.age";
      owner = config.vars.username;
    };
  };

  home-manager.users."${config.vars.username}" =
    let homeManagerConfig = config.home-manager.users."${config.vars.username}"; in {
      accounts.email.maildirBasePath = "${homeManagerConfig.xdg.dataHome}/mail";
      accounts.email.accounts.fastmail-local = {
        primary = true;
        address = "bruno@inec.cc";
        userName = "bruno@inec.cc";
        passwordCommand = "cat ${config.age.secrets.fastmailToken.path}";
        realName = "Bruno Inec";
        flavor = "fastmail.com";
        notmuch.enable = true;
        mujmap = {
          enable = true;
          settings = {
            fqdn = "fastmail.com";
            lowercase = true;
          };
        };
        himalaya = {
          enable = true;
          settings = {
            backend = "maildir";
            maildir-root-dir = homeManagerConfig.accounts.email.maildirBasePath;
            sender = "sendmail";
            sendmail-cmd = "${pkgs.mujmap}/bin/mujmap send";
          };
        };
      };

      programs = {
        mujmap.enable = true;
        notmuch.enable = true;
        himalaya = {
          enable = true;
          settings.downloads-dir = "${config.vars.home}/${config.vars.downloadFolder}";
        };
      };

      home.packages = with pkgs; [
        (writeShellScriptBin
          "himalaya-tui"
          ''
            ${skim}/bin/sk -c '${himalaya}/bin/himalaya list -s 200' \
              --preview "${himalaya}/bin/himalaya read {1} -t html | \
              ${w3m}/bin/w3m -T text/html" \
              --bind 'space:execute(${himalaya}/bin/himalaya reply {1})' \
              --bind 'esc:execute(${himalaya}/bin/himalaya delete {1})' \
              --bind 'ctrl-f:execute(${himalaya}/bin/himalaya config forward {1})' \
              --reverse --header-lines=2 --ansi
          '')
      ];
    };
}
