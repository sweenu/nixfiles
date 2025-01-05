{ config, ... }:

let
  simpleTorrentDir = "/opt/simple-torrent";
in
{
  virtualisation.arion.projects.simple-torrent.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.simple-torrent.service = {
      image = "boypt/cloud-torrent";
      container_name = "simple-torrent";
      volumes = [
        "${simpleTorrentDir}/downloads:/downloads"
        "${simpleTorrentDir}/torrents:/torrents"
      ];
      networks = [ config.services.traefik.staticConfigOptions.providers.docker.network ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-simple-torrent.service" = "simple-torrent";
        "traefik.http.routers.to-simple-torrent.middlewares" = "authelia@docker";
        "traefik.http.services.simple-torrent.loadbalancer.server.port" = "3000";
      };
    };
  };

  services.restic.backups.opt.exclude = [ simpleTorrentDir ];
}
