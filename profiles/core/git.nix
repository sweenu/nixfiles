{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.git = {
    enable = true;
    userEmail = config.vars.email;
    userName = "Bruno Inec";
    ignores = [ "venv" ".env" "pyrightconfig.json" "shell.nix" ".envrc" ".direnv" ];
    extraConfig = {
      pull.rebase = "true";
      branch.autosetuprebase = "always";
      init.defaultBranch = "master";
      gpg.format = "ssh";
      user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";
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
        plus-style = "syntax #012800";
        minus-style = "syntax #340001";
        syntax-theme = "Monokai Extended";
        navigate = "true";
      };
    };
  };
}
