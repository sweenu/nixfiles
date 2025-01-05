{ self, config, ... }:

let
  wordpressDir = "/opt/wordpress";
  wordpressDataDir = "${wordpressDir}/data";
  wordpressSecretsDir = "${config.age.secretsDir}/wordpress";
in
{
  age.secrets = {
    "wordpress/dbPassword" = {
      file = "${self}/secrets/wordpress/db_password.age";
      mode = "644";
    };
  };

  virtualisation.arion.projects.wordpress.settings = {
    networks.traefik.external = true;
    services = rec {
      wordpress.service = {
        image = "wordpress:6.5";
        container_name = "wordpress";
        depends_on = [ "db" ];
        volumes = [
          "${wordpressDataDir}/data:/var/www/html"
          "${wordpressSecretsDir}:${wordpressSecretsDir}:ro"
        ];
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        environment = {
          WORDPRESS_DB_HOST = "db";
          WORDPRESS_DB_NAME = db.service.environment.MYSQL_DATABASE;
          WORDPRESS_DB_USER = db.service.environment.MYSQL_USER;
          WORDPRESS_DB_PASSWORD_FILE = db.service.environment.MYSQL_PASSWORD_FILE;
          WORDPRESS_DEBUG = "true";
        };
        labels = {
          "traefik.enable" = "true";
        };
      };

      db.service = {
        image = "mysql:8";
        container_name = "wordpress_db";
        networks = [ "default" ];
        environment = {
          MYSQL_DATABASE = "wordpress";
          MYSQL_USER = "wordpress";
          MYSQL_PASSWORD_FILE = config.age.secrets."wordpress/dbPassword".path;
          MYSQL_RANDOM_ROOT_PASSWORD = "1";
        };
        volumes = [
          "db:/var/lib/mysql"
          "${wordpressSecretsDir}:${wordpressSecretsDir}:ro"
        ];
      };
    };
    docker-compose.volumes = {
      db = { };
    };
  };
}
