{ config, ... }:
let
  portainerDir = "/opt/portainer";
in
{
  virtualisation.arion.projects.portainer.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.portainer.service = {
      image = "portainer/portainer-ce:latest";
      container_name = "portainer";
      networks = [ config.services.traefik.staticConfigOptions.providers.docker.network ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "${portainerDir}:/data"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-portainer.service" = "portainer";
        "traefik.http.services.portainer.loadbalancer.server.port" = "9000";
      };
    };
  };
}
