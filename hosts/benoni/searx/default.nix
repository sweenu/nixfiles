{ self, config, pkgs, ... }:

let
  settingsFile = pkgs.writeText "searxng_settings.yml" (builtins.readFile ./settings.yml);
in
{
  age.secrets."searx/envFile".file = "${self}/secrets/searx/env.age";

  virtualisation.arion.projects.searx.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.searx.service = {
      image = "searxng/searxng";
      container_name = "searx";
      volumes = [ "${settingsFile}:/etc/searxng/settings.yml:ro" ];
      networks = [ config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
      environment = {
        BASE_URL = "https://searx.${config.vars.domainName}";
      };
      env_file = [ config.age.secrets."searx/envFile".path ]; # sets SEARXNG_SECRET
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-searx.service" = "searx";
        "traefik.http.routers.to-searx.middlewares" = "authelia@docker";
        "traefik.http.services.searx.loadbalancer.server.port" = "8080";
      };
    };
  };
}
