{ self, config, pkgs, ... }:

let
  dendriteSecretsDir = "${config.age.secretsDir}/dendrite";
  dendriteConfig = let dbEnv = config.virtualisation.arion.projects.dendrite.settings.services.db.service.environment; in pkgs.substituteAll {
    src = ./dendrite.yaml;
    inherit (config.vars) domainName;
    pgDB = dbEnv.POSTGRES_DB;
    pgUser = dbEnv.POSTGRES_USER;
  };
in
{
  age.secrets = {
    "dendrite/dbPassword".file = "${self}/secrets/dendrite/db_password.age";
    "dendrite/matrixKey" = {
      file = "${self}/secrets/dendrite/matrix_key.age";
      mode = "600";
    };
    "dendrite/serverCrt" = {
      file = "${self}/secrets/dendrite/server_crt.age";
      mode = "644";
    };
    "dendrite/serverKey" = {
      file = "${self}/secrets/dendrite/server_key.age";
      mode = "600";
    };
  };

  virtualisation.arion.projects.dendrite.settings = {
    networks.traefik.external = true;

    services = rec {
      dendrite.service = {
        image = "matrixdotorg/dendrite-monolith:v0.13.6";
        container_name = "dendrite";
        environment = {
          POSTGRES_PASSWORD_FILE = db.service.environment."POSTGRES_PASSWORD_FILE";
        };
        volumes = with builtins; let etc = "/etc/dendrite"; in [
          "${dendriteConfig}:${etc}/dendrite.yaml"
          (concatStringsSep ":" [ config.age.secrets."dendrite/matrixKey".path "${etc}/matrix_key.pem" ])
          (concatStringsSep ":" [ config.age.secrets."dendrite/serverCrt".path "${etc}/server.crt" ])
          (concatStringsSep ":" [ config.age.secrets."dendrite/serverKey".path "${etc}/server.key" ])
          "dendrite_media:/var/dendrite/media"
          "dendrite_jetstream:/var/dendrite/jetstream"
          "dendrite_search_index:/var/dendrite/searchindex"
        ];
        networks = [ "default" config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
        ports = [ "8448:8448" ];
        depends_on.db.condition = "service_healthy";
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-dendrite.service" = "acp";
          "traefik.http.routers.to-dendrite.middlewares" = "authelia@docker";
          "traefik.http.services.dendrite.loadbalancer.server.port" = "8008";
        };
      };

      db.service = {
        image = "postgres:16";
        container_name = "dendrite_db";
        volumes = [
          "dendrite_db:/var/lib/postgresql/data"
          "${dendriteSecretsDir}:${dendriteSecretsDir}:ro"
        ];
        networks = [ "default" ];
        environment = {
          POSTGRES_USER = "dendrite";
          POSTGRES_PASSWORD_FILE = config.age.secrets."dendrite/dbPassword".path;
          POSTGRES_DB = "dendrite";
        };
        healthcheck = {
          test = [ "CMD-SHELL" "pg_isready -U dendrite" ];
          interval = "5s";
          timeout = "5s";
          retries = 5;
        };
      };
    };
    docker-compose.volumes = {
      dendrite_db = { };
      dendrite_media = { };
      dendrite_jetstream = { };
      dendrite_search_index = { };
    };
  };
}
