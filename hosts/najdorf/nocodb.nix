{ self, config, ... }:

let
  fqdn = "nocodb.${config.vars.domainName}";
  url = "https://${fqdn}";
  nocodbDir = "/opt/nocodb";
  port = 8097;
in
{
  age.secrets = {
    "nocodb/envFile".file = "${self}/secrets/nocodb/env.age";
  };

  virtualisation.arion.projects.nocodb.settings = {
    networks.traefik.external = true;

    services = {
      nocodb.service = {
        image = "nocodb/nocodb:0.301.1";
        container_name = "nocodb";
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        volumes = [ "${nocodbDir}:/usr/app/data" ];
        ports = [ "8041:${builtins.toString port}" ];
        depends_on = [
          "db"
          "redis"
        ];
        environment = {
          NC_REDIS_URL = "redis://redis";
          NC_ADMIN_EMAIL = config.vars.email;
          NC_PUBLIC_URL = url;
          NC_INVITE_ONLY_SIGNUP = "true";
          NC_SANITIZE_COLUMN_NAME = "true";
          NC_DISABLE_SUPPORT_CHAT = "true";
          NC_SMTP_FROM = "NocoDB Admin <${config.vars.email}>";
          NC_SMTP_HOST = config.vars.smtp.host;
          NC_SMTP_PORT = builtins.toString config.vars.smtp.port;
          NC_SMTP_USERNAME = config.vars.smtp.user;
          NC_SMTP_SECURE = "true";
          NC_SMTP_REJECT_UNAUTHORIZED = "true";
          PORT = builtins.toString port;
        };
        env_file = [ config.age.secrets."nocodb/envFile".path ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-nocodb.service" = "nocodb";
          "traefik.http.services.nocodb.loadbalancer.server.port" = builtins.toString port;
        };
      };

      redis.service = {
        image = "redis:8";
        networks = [ "default" ];
      };

      db.service =
        let
          version = "16";
        in
        {
          image = "postgres:${version}";
          networks = [ "default" ];
          environment = rec {
            POSTGRES_USER = "nocodb";
            POSTGRES_DB = POSTGRES_USER;
          };
          env_file = [ config.age.secrets."nocodb/envFile".path ];
          volumes = [
            # Directory stucture simplifies upgrades with https://github.com/tianon/docker-postgres-upgrade
            "${nocodbDir}/pg/${version}/data:/var/lib/postgresql/data"
          ];
        };
    };
  };
}
