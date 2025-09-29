{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.git = {
    enable = true;
    userEmail = config.vars.email;
    userName = "sweenu";
    ignores = [
      "venv"
      ".env"
      "pyrightconfig.json"
      "shell.nix"
      ".envrc"
      ".direnv"
    ];
    extraConfig = {
      pull.rebase = "true";
      branch.autosetuprebase = "always";
      init.defaultBranch = "master";
      gpg.format = "ssh";
      user.signingKey = "${config.vars.sshPublicKey}";
      commit.gpgSign = "true";
      tag.gpgSign = "true";
    };
    aliases = {
      ll = "log --graph --date='short' --color=always --pretty=format:'%Cgreen%h %Cred%<(15,trunc)%an %Cblue%cd %Creset%s'";
    };
    delta = {
      enable = true;
      options = {
        dark = true;
        syntax-theme = "Monokai Extended";
        navigate = "true";
      };
    };
  };
}
