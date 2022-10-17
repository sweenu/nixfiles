{ pkgs, config, ... }:

{
  systemd.user.services.snapclient = {
    wantedBy = [ "default.target" ];
    after = [ "pipewire.service" ];
    description = "Snapcast client";
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h ${config.vars.grunfeldIPv4} --player pulse --mixer hardware";
      Restart = "on-failure";
    };
  };
}
