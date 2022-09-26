{ pkgs, ... }:

{
  systemd.user.services.snapclient = {
    wantedBy = [
      "pipewire.service"
    ];
    after = [
      "pipewire.service"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h 192.168.0.24 --player pulse --mixer hardware";
    };
  };
}
