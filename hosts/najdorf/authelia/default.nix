{ self, config, pkgs, ... }:

let
  autheliaDataDir = "/data";
  usersFilePath = "${autheliaSecretsDir}/usersFile";
  autheliaPort = "9091";
  autheliaSecretsDir = "${config.age.secretsDir}/authelia";
  autheliaConfig = pkgs.substituteAll {
    src = ./config.yml;
    inherit (config.vars) email domainName smtpUsername smtpHost smtpPort;
    inherit autheliaDataDir autheliaPort usersFilePath;
    ntpAddress = "${builtins.head config.networking.timeServers}:123";
  };
in
{
  age.secrets = {
    "authelia/jwtSecret".file = "${self}/secrets/authelia/jwt_secret.age";
    "authelia/sessionSecret".file = "${self}/secrets/authelia/session_secret.age";
    "authelia/storageEncryptionKey".file = "${self}/secrets/authelia/storage_encryption_key.age";
    "authelia/usersFile".file = "${self}/secrets/authelia/users.age";
    "authelia/smtpPassword".file = "${self}/secrets/smtp_password.age";
  };

  virtualisation.arion.projects.authelia.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.authelia.service = {
      image = "authelia/authelia:4.37";
      container_name = "authelia";
      expose = [ autheliaPort ];
      volumes = [
        "authelia:${autheliaDataDir}"
        "${autheliaConfig}:/config/configuration.yml:ro"
        "${autheliaSecretsDir}:${autheliaSecretsDir}:ro"
      ];
      networks = [ config.virtualisation.arion.projects.traefik.settings.networks.traefik.name ];
      environment = {
        TZ = config.vars.timezone;
        AUTHELIA_JWT_SECRET_FILE = config.age.secrets."authelia/jwtSecret".path;
        AUTHELIA_SESSION_SECRET_FILE = config.age.secrets."authelia/sessionSecret".path;
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = config.age.secrets."authelia/storageEncryptionKey".path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.age.secrets."authelia/smtpPassword".path;
      };
      labels = {
        "traefik.enable" = "true";

        # Forward auth
        "traefik.http.middlewares.authelia.forwardauth.address" = "http://authelia:${autheliaPort}/api/verify?rd=https://authelia.${config.vars.domainName}/";
        "traefik.http.middlewares.authelia.forwardauth.trustForwardHeader" = "true";
        "traefik.http.middlewares.authelia.forwardauth.authResponseHeaders" = "Remote-User, Remote-Groups";

        # Security headers
        "traefik.http.middlewares.authelia-headers.headers.browserXssFilter" = "true";
        "traefik.http.middlewares.authelia-headers.headers.customFrameOptionsValue" = "SAMEORIGIN";
        "traefik.http.middlewares.authelia-headers.headers.customResponseHeaders.Cache-Control" = "no-store";
        "traefik.http.middlewares.authelia-headers.headers.customResponseHeaders.Pragma" = "no-cache";
        "traefik.http.routers.to-authelia.middlewares" = "authelia-headers";
      };
    };
    docker-compose.volumes.authelia = { };
  };
}
