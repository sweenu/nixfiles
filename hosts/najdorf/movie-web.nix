{ self, config, ... }:

{
  age.secrets = {
    "movie-web/env".file = "${self}/secrets/movie-web/env.age";
    "movie-web/backendEnv".file = "${self}/secrets/movie-web/backend_env.age";
    "movie-web/dbPassword".file = "${self}/secrets/movie-web/db_password.age";
  };

  virtualisation.arion.projects.movie-web.settings = {
    networks.traefik.external = true;
    services = rec {
      movie-web.service = {
        # image = "ghcr.io/movie-web/movie-web:latest";
        image = "rg.fr-par.scw.cloud/sweenu/movie-web";
        container_name = "movie-web";
        networks = [ "default" config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
        environment = {
          VITE_CORS_PROXY_URL = "http://proxy:3000";
          VITE_BACKEND_URL = "http://backend";
          VITE_NORMAL_ROUTER = "true";
        };
        env_file = [ config.age.secrets."movie-web/env".path ];
        labels = {
          "traefik.enable" = "true";
        };
      };

      proxy.service = {
        image = "ghcr.io/movie-web/backend:latest";
        networks = [ "default" ];
      };

      backend.service = {
        image = "ghcr.io/movie-web/backend:latest";
        networks = [ "default" ];
        environment = {
          MWB_POSTGRES__CONNECTION = "postgresql://db";
          MWB_POSTGRES__MIGRATE_ON_BOOT = "true";
          MWB_META__NAME = "movie-web";
          POSTGRES_USER = db.service.environment."POSTGRES_USER";
          POSTGRES_PASSWORD_FILE = db.service.environment."POSTGRES_PASSWORD_FILE";
        };
        env_file = [ config.age.secrets."movie-web/backendEnv".path ];
      };

      db.service = {
        image = "postgres:16";
        networks = [ "default" ];
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD_FILE = config.age.secrets."movie-web/dbPassword".path;
        };
        volumes = [
          "movie-web_db:/var/lib/postgresql/data"
          "${config.age.secretsDir}/movie-web:${config.age.secretsDir}/movie-web:ro"
        ];
      };
    };

    docker-compose.volumes = {
      movie-web_db = { };
    };
  };
}
