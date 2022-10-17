{ config, ... }:

let
  searxDir = "/opt/searx";
in
{
  virtualisation.arion.projects.searx.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.searx.service = {
      image = "searxng/searxng";
      container_name = "searx";
      volumes = [ "${searxDir}:/etc/searxng" ];
      networks = [ config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
      environment = rec {
        BASE_URL = "https://searx.${config.vars.domainName}";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-searx.service" = "searx";
        "traefik.http.routers.to-searx.middlewares" = "authelia@docker";
        "traefik.http.services.searx.loadbalancer.server.port" = "8080";
      };
    };
  };
}
