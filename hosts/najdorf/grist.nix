{ self
, config
, ...
}:

let
  gristDir = "/opt/grist";
in
{
  age.secrets = {
    "grist/envFile".file = "${self}/secrets/grist/env.age";
  };

  virtualisation.arion.projects.grist.settings = {
    networks.traefik.external = true;

    services = {
      grist.service = {
        image = "gristlabs/grist:1.6";
        container_name = "grist";
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        volumes = [
          "${gristDir}:/persist"
        ];
        environment = {
          APP_HOME_URL = "https://grist.${config.vars.domainName}";
          GRIST_SINGLE_ORG = "grist";
          GRIST_LOG_LEVEL = "warn";
          GRIST_FORCE_LOGIN = "true";
          GRIST_SANDBOX_FLAVOR = "gvisor";
          GRIST_DEFAULT_EMAIL = config.vars.email;
        };
        env_file = [ config.age.secrets."grist/envFile".path ]; # sets GRIST_SESSION_SECRET
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-grist.service" = "grist";
          "traefik.http.services.grist.loadbalancer.server.port" = "8484";
          "traefik.http.routers.to-grist.middlewares" = "authelia@file";
        };
      };
    };
  };
}
