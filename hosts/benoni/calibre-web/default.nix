{ self, config, pkgs, ... }:

let
  calibreDir = "/opt/calibre";
  calibreDataDir = "${calibreDir}/data";
in
{
  age.secrets.resticCalibrePassword.file = "${self}/secrets/restic/calibre.age";

  services.restic = {
    backups.calibre = {
      initialize = true;
      repository = "sftp:root@grunfeld:/data/backups/calibre";
      paths = [ "/opt/calibre" ];
      pruneOpts = [ "--keep-last 36" "--keep-daily 14" "--keep-weekly 12" ];
      timerConfig = { OnCalendar = "*-*-* *:00:00"; RandomizedDelaySec = "5m"; };
      passwordFile = config.age.secrets.resticCalibrePassword.path;
    };
  };

  virtualisation.arion.projects.calibre-web.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.calibre.service = {
      image = "lscr.io/linuxserver/calibre-web:0.6.19";
      container_name = "calibre-web";
      volumes = [
        "${calibreDir}/config:/config"
        "${calibreDataDir}:/books"
      ];
      networks = [ config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
      environment = {
        TZ = "Europe/Paris";
        PUID = "0";
        PGID = "0";
      };
      labels = {
        "traefik.enable" = "true";

        "traefik.http.routers.to-calibre.service" = "calibre";
        "traefik.http.services.calibre.loadbalancer.server.port" = "8083";
      };
    };
  };
}
