{ config, ... }:

let
  calibreDir = "/opt/calibre";
  calibreDataDir = "${calibreDir}/data";
in
{
  virtualisation.arion.projects.calibre-web.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.calibre.service = {
      image = "lscr.io/linuxserver/calibre-web:0.6.20";
      container_name = "calibre-web";
      volumes = [
        "${calibreDir}/config:/config"
        "${calibreDataDir}:/books"
      ];
      networks = [ config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
      environment = {
        TZ = config.vars.timezone;
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
