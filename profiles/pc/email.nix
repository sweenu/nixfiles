{ self, config, pkgs, ... }:

{
  age.secrets = {
    googleAppPasswordFile = {
      file = "${self}/secrets/himalaya/google_app_password.age";
      owner = config.vars.username;
    };
  };

  home-manager.users."${config.vars.username}" = {
    accounts.email.maildirBasePath = "${config.vars.home}/.mail";
    accounts.email.accounts.gmail-local = {
      primary = true;
      address = config.vars.email;
      realName = "Bruno Inec";
      userName = config.vars.smtpUsername;
      passwordCommand = "cat ${config.age.secrets.googleAppPasswordFile.path}";
      flavor = "gmail.com";
      himalaya.enable = true;
    };

    programs = {
      himalaya.enable = true;
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
