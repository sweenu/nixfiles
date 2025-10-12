{ self, config, ... }:

let
  windmillDir = "/opt/windmill";
  fqdn = "windmill.${config.vars.domainName}";
  url = "https://${fqdn}";
in
{
  age.secrets = {
    "windmill/oidcClientSecretDigest" = {
      file = "${self}/secrets/windmill/oidc_client_secret_digest.age";
      owner = config.services.authelia.instances.main.user;
    };
    "windmill/envFile".file = "${self}/secrets/windmill/env.age";
  };

  virtualisation.arion.projects.windmill.settings = {
    networks.traefik.external = true;

    services = {
      windmill-postgres.service = {
        image = "postgres:15.14";
        container_name = "windmill-postgres";
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        volumes = [
          "${windmillDir}/postgres:/var/lib/postgresql/data"
        ];
        env_file = [ config.age.secrets."windmill/envFile".path ];
        healthcheck = {
          test = [
            "CMD-SHELL"
            "pg_isready -U postgres"
          ];
          interval = "10s";
          timeout = "5s";
          retries = 5;
        };
      };

      windmill-server.service = {
        image = "ghcr.io/windmill-labs/windmill-full:latest";
        container_name = "windmill-server";
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        depends_on.windmill-postgres.condition = "service_healthy";
        env_file = [ config.age.secrets."windmill/envFile".path ];
        environment = {
          MODE = "server";
          BASE_URL = url;
          RUST_LOG = "WARN";
        };
        volumes = [
          "${windmillDir}/data:/tmp/windmill"
        ];
        labels = {
          "traefik.enable" = "true";

          "traefik.http.routers.to-windmill.rule" = "Host(`${fqdn}`)";
          "traefik.http.routers.to-windmill.service" = "windmill";
          "traefik.http.routers.to-windmill.middlewares" = "authelia@file";
          "traefik.http.services.windmill.loadbalancer.server.port" = "8000";

          # Public OIDC callback router (no forward-auth to avoid loops)
          "traefik.http.routers.to-windmill-callback.rule" =
            "Host(`${fqdn}`) && PathPrefix(`/user/login_callback`)";
          "traefik.http.routers.to-windmill-callback.service" = "windmill";
        };
      };

      # Windmill Worker
      windmill-worker.service = {
        image = "ghcr.io/windmill-labs/windmill-full:latest";
        container_name = "windmill-worker";
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        depends_on.windmill-postgres.condition = "service_healthy";
        env_file = [ config.age.secrets."windmill/envFile".path ];
        environment = {
          MODE = "worker";
          WORKER_GROUP = "default";
          BASE_URL = url;
          RUST_LOG = "warn";
          KEEP_JOB_DIR = "false";
        };
        volumes = [
          "${windmillDir}/worker-cache:/tmp/windmill/cache"
        ];
      };
    };
  };

  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = "windmill";
      client_name = "Windmill";
      client_secret = ''{{ secret "${config.age.secrets."windmill/oidcClientSecretDigest".path}" }}'';
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
      authorization_policy = "one_factor";
      redirect_uris = [ "${url}/user/login_callback/authelia" ];
      pre_configured_consent_duration = "1y";
    }
  ];

  # services.windmill = {
  #   enable = true;
  #   baseUrl = url;
  #   database.createLocally = true;
  # };

  # systemd.services.windmill-server.serviceConfig.ExecStart = lib.mkForce windmillBin;
  # systemd.services.windmill-worker.serviceConfig.ExecStart = lib.mkForce windmillBin;
  # systemd.services.windmill-worker-native.serviceConfig.ExecStart = lib.mkForce windmillBin;

  # services.traefik.dynamicConfigOptions.http = rec {
  #   routers.to-windmill = {
  #     rule = "Host(`${fqdn}`)";
  #     service = "windmill";
  #     middlewares = "authelia";
  #   };
  #   services."${routers.to-windmill.service}".loadBalancer.servers = [
  #     {
  #       url = "http://127.0.0.1:${builtins.toString config.services.windmill.serverPort}";
  #     }
  #   ];
  # };
}
