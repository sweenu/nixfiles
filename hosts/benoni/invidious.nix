{ self, config, pkgs, lib, ... }:

{
  age.secrets = {
    "invidious/dbPassword".file = "${self}/secrets/invidious/db_password.age";
  };

  virtualisation.arion.projects.invidious.settings = {
    networks.traefik.external = true;
    services = rec {
      invidious.service = {
        image = "quay.io/invidious/invidious:latest";
        container_name = "invidious";
        links = [ "db" ];
        networks = [ "default" config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
        environment = {
          INVIDIOUS_CONFIG = ''
            db:
              dbname: ${db.service.environment.POSTGRES_DB}
              user: ${db.service.environment.POSTGRES_USER}
              password: ${db.service.environment.POSTGRES_PASSWORD_FILE}
              host: db
              port: 5432
            check_tables: true
            # external_port:
            # domain:
            # https_only: false
            statistics_enabled: false
          '';
        };
        healthcheck = {
          test = "wget -nv --tries=1 --spider http://127.0.0.1:3000/api/v1/comments/jNQXAC9IVRw || exit 1";
          interval = "30s";
          timeout = "5s";
          retries = "2";
        };

        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-invidious.service" = "invidious";
          "traefik.http.routers.to-invidious.middlewares" = "authelia@docker";
          "traefik.http.services.invidious.loadbalancer.server.port" = "3000";
        };
      };

      db.service = {
        image = "docker.io/library/postgres:14";
        container_name = "invidious_db";
        networks = [ "default" ];
        environment = {
          "POSTGRES_DB" = "invidious";
          "POSTGRES_USER" = "invidious";
          "POSTGRES_PASSWORD_FILE" = config.age.secrets."invidious/dbPassword".path;
        };
        volumes = [
          "invidious_db:/var/lib/postgresql/data"
        ];
        healthcheck.test = [ "CMD-SHELL" "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB" ];
      };
    };

    docker-compose.raw.volumes.invidious_db = { };
  };
}
