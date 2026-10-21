{
  config,
  lib,
  pkgs,
  ...
}:

let
  sendspin = lib.getExe' pkgs.python3Packages.sendspin "sendspin";
  massServer = "ws://${config.vars.staticIP}:8927/sendspin";
in
{
  home-manager.users."${config.vars.username}".systemd.user.services.sendspin-player = {
    Unit = {
      Description = "Sendspin player: expose this host as a Music Assistant speaker";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = lib.concatStringsSep " " [
        sendspin
        "daemon"
        # --url rather than mDNS so this works off-LAN over Tailscale too.
        "--url ${massServer}"
        "--name ${config.networking.hostName}"
        "--audio-device pipewire"
        # Software gain on the stream; the default would drive the default sink,
        # i.e. the volume of every other app on the laptop.
        "--hardware-volume false"
      ];
      # MA needs 15s to re-wrap a reconnected client, so never stay stopped.
      Restart = "always";
      RestartSec = "10s";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
