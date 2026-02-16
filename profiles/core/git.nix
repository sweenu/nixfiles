{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs = {
    git = {
      enable = true;
      ignores = [
        "venv"
        ".env"
        ".envrc"
        ".direnv"
        "devenv.*"
        ".devenv.*"
        ".devenv/"
      ];
      settings = {
        user = {
          email = config.vars.email;
          name = config.vars.username;
          signingKey = "${config.vars.sshPublicKey}";
        };
        pull.rebase = "true";
        push.autoSetupRemote = "true";
        branch.autosetuprebase = "always";
        init.defaultBranch = "main";
        gpg.format = "ssh";
        commit.gpgSign = "true";
        tag.gpgSign = "true";
        alias = {
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

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    gh-dash.enable = true;
  };
}
