{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    home = {
      username = "${config.vars.username}";
      homeDirectory = "${config.vars.home}";
      stateVersion = config.system.stateVersion;
      sessionVariables = {
        EDITOR = "kak";
        VISUAL = "kak";
        PAGER = "less -R";
        TERM = "${config.vars.terminal}";
        BROWSER = "${config.vars.defaultBrowser}";
      };
      packages = with pkgs; [
        neofetch
        rclone
      ];
    };
    programs = {
      bottom.enable = true;
      broot = {
        enable = true;
        settings.modal = true;
      };
      bat = {
        enable = true;
        config = { theme = "zenburn"; pager = "less"; };
      };
      home-manager.enable = true;
      skim = rec {
        enable = true;
        defaultCommand = "fd --type f --hidden --exclude '.git'";
        defaultOptions = [ "--height 40%" "--inline-info" ];
        changeDirWidgetCommand = "fd --type d --hidden --exclude '.git'";
        fileWidgetCommand = defaultCommand;
        fileWidgetOptions = [ "--preview 'bat --color always {} 2> /dev/null | head -200; highlight -O ansi -l {} ^ /dev/null | head -200 || cat {} ^ /dev/null | head -200'" ];
        historyWidgetOptions = [ "--tac" ];
      };
    };
  };
}
