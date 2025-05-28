{ config, ... }:
{
  home-manager.users."${config.vars.username}" = {
    programs.yazi = {
      enable = true;
    };
    programs.fish.functions.y = {
      body = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
      description = "Change the current directory through yazi";
    };
  };
}
