{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs = {
    git = {
      enable = true;
      ignores = [
        "venv"
        ".env"
        "pyrightconfig.json"
        ".envrc"
        ".direnv"
      ];
      settings = {
        user = {
          email = config.vars.email;
          name = "sweenu";
          signingKey = "${config.vars.sshPublicKey}";
        };
        pull.rebase = "true";
        branch.autosetuprebase = "always";
        blame.ignoreRevsFile = ".git-blame-ignore-revs";
        init.defaultBranch = "main";
        gpg.format = "ssh";
        commit.gpgSign = "true";
        tag.gpgSign = "true";
        aliases = {
          ll = "log --graph --date='short' --color=always --pretty=format:'%Cgreen%h %Cred%<(15,trunc)%an %Cblue%cd %Creset%s'";
        };
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = true;
        syntax-theme = "Monokai Extended";
        navigate = "true";
      };
    };
  };
}
