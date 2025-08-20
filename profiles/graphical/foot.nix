{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.foot = {
    enable = false;
    server.enable = false;
    settings = {
      main = {
        shell = "${pkgs.tmux}/bin/tmux";
        font = "${config.vars.defaultMonoFont}:size=10";
        pad = "10x10";
        selection-target = "both";
      };

      colors = rec {
        background = "1b2b34";
        foreground = "d8dee9";

        regular0 = "343d46";
        regular1 = "ec5f67";
        regular2 = "99c794";
        regular3 = "fac863";
        regular4 = "6699cc";
        regular5 = "c594c5";
        regular6 = "5fb3b3";
        regular7 = "cdd3de";

        bright0 = regular0;
        bright1 = regular1;
        bright2 = regular2;
        bright3 = regular3;
        bright4 = regular4;
        bright5 = regular5;
        bright6 = regular6;
        bright7 = regular7;
      };
    };
  };
}
