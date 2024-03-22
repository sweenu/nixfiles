{ self, config, pkgs, lib, ... }:

let
  nextcloudDir = "/opt/nextcloud";
  nextcloudDataDir = "${nextcloudDir}/data";
  nextcloudSecretsDir = "${config.age.secretsDir}/nextcloud";
  nextcloudContainerDir = "/var/www/html";
  nextcloudVolumes = [
    "nextcloud:${nextcloudContainerDir}"
    "${nextcloudDataDir}/config:${nextcloudContainerDir}/config"
    "${nextcloudDataDir}/data:${nextcloudContainerDir}/data"
    "${nextcloudDataDir}/custom_apps:${nextcloudContainerDir}/custom_apps"
    "${nextcloudSecretsDir}:${nextcloudSecretsDir}:ro"
  ];
in
{
  age.secrets = {
    "nextcloud/adminUser".file = "${self}/secrets/nextcloud/admin_user.age";
    "nextcloud/adminPassword".file = "${self}/secrets/nextcloud/admin_password.age";
    "nextcloud/envFile".file = "${self}/secrets/nextcloud/env.age";
    "nextcloud/dbPassword".file = "${self}/secrets/nextcloud/db_password.age";
  };

  virtualisation.arion.projects.nextcloud.settings = let version = "28"; in {
    networks.traefik.external = true;

    services = rec {
      nextcloud.service = {
        image = "nextcloud:${version}";
        container_name = "nextcloud";
        depends_on = [ "db" ];
        networks = [ "default" config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
        volumes = nextcloudVolumes;
        environment = {
          POSTGRES_HOST = "db";
          POSTGRES_DB = "nextcloud";
          POSTGRES_USER = db.service.environment."POSTGRES_USER";
          POSTGRES_PASSWORD_FILE = db.service.environment."POSTGRES_PASSWORD_FILE";
          NEXTCLOUD_ADMIN_USER_FILE = config.age.secrets."nextcloud/adminUser".path;
          NEXTCLOUD_ADMIN_PASSWORD_FILE = config.age.secrets."nextcloud/adminPassword".path;
          NEXTCLOUD_TRUSTED_DOMAINS = "nextcloud.${config.vars.domainName}";
          TRUSTED_PROXIES = "172.16.0.0/12";
          OVERWRITEPROTOCOL = "https";
          SMTP_HOST = config.vars.smtpHost;
          SMTP_PORT = config.vars.smtpPort;
          SMTP_NAME = config.vars.smtpUsername;
          SMTP_SECURE = "tls";
          MAIL_FROM_ADDRESS = config.vars.email;
          MAIL_DOMAIN = builtins.elemAt (lib.strings.splitString "@" config.vars.email) 1;
          PHP_UPLOAD_LIMIT = "16G";
          APACHE_BODY_LIMIT = "0";
        };
        env_file = [ config.age.secrets."nextcloud/envFile".path ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-nextcloud.middlewares" = "nextcloud-redirectregex";
          "traefik.http.middlewares.nextcloud-redirectregex.redirectregex.permanent" = "true";
          "traefik.http.middlewares.nextcloud-redirectregex.redirectregex.regex" = "https://(.*)/.well-known/(card|cal)dav";
          "traefik.http.middlewares.nextcloud-redirectregex.redirectregex.replacement" = "https://\$\${1}/remote.php/dav/";
        };
      };

      db.service = {
        image = "postgres:11";
        container_name = "nextcloud_db";
        networks = [ "default" ];
        environment = {
          POSTGRES_USER = "postgres";
          POSTGRES_PASSWORD_FILE = config.age.secrets."nextcloud/dbPassword".path;
        };
        volumes = [
          "${nextcloudDir}/pg_data:/var/lib/postgresql/data"
          "${nextcloudSecretsDir}:${nextcloudSecretsDir}:ro"
        ];
      };

      cron.service = {
        image = "nextcloud:${version}";
        volumes = nextcloudVolumes;
        entrypoint = "/cron.sh";
        depends_on = [ "db" ];
      };
    };

    docker-compose.volumes = {
      nextcloud = { };
    };
  };

  services.restic = {
    backups.nextcloud = {
      initialize = true;
      repository = "sftp:root@grunfeld:/data/backups/nextcloud";
      paths = [ nextcloudDir ];
      pruneOpts = [ "--keep-last 36" "--keep-daily 14" "--keep-weekly 12" ];
      timerConfig = {
        OnCalendar = "*-*-* *:00:00"; # every hour
        RandomizedDelaySec = "5m";
      };
      passwordFile = config.age.secrets.resticPassword.path;
      backupPrepareCommand =
        let
          servicesSettings = config.virtualisation.arion.projects.nextcloud.settings.services;
          dbContainerName = servicesSettings.db.service.container_name;
          postgresUser = servicesSettings.db.service.environment.POSTGRES_USER;
          postgresDatabase = servicesSettings.nextcloud.service.environment.POSTGRES_DB;
        in
        # To restore from dump: cat /opt/nextcloud/db.dump | sudo docker exec -i nextcloud_db psql -U postgres
        ''
          ${pkgs.docker}/bin/docker exec ${dbContainerName} \
          pg_dump -U ${postgresUser} -d ${postgresDatabase} > \
          ${nextcloudDir}/db.dump
        '';
      backupCleanupCommand = "${pkgs.curl}/bin/curl https://hc-ping.com/3e004d53-809a-4386-bb45-a36fc919120a";
    };
  };
}
