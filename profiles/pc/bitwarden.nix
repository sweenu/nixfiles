{
  config,
  lib,
  pkgs,
  ...
}:
let
  exe = lib.getExe pkgs.bitwarden-desktop;
in
{
  home-manager.users."${config.vars.username}".systemd.user.services.bitwarden = {
    Unit = {
      Description = "Bitwarden Desktop Client";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = exe;
      KillMode = "process";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      RestrictRealtime = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
