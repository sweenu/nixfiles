{
  self,
  config,
  ...
}:

let
  fqdn = "dawarich.${config.vars.tailnetName}";
  tsidpUrl = "https://idp.${config.vars.tailnetName}";
  oidcClientId = "924f509529c388c8740c7407492777ea";
  oidcRedirectUri = "https://${fqdn}/users/auth/openid_connect/callback";

  photonPort = "2322";
  geocodingThreads = 6;
in

{
  age.secrets = {
    "dawarich/secretKeyBaseFile".file = "${self}/secrets/dawarich/secret_key_base.age";
    "dawarich/oidcClientSecretEnvFile".file = "${self}/secrets/dawarich/oidc_client_secret_env.age";
  };

  services.dawarich = {
    enable = true;
    configureNginx = false;
    localDomain = fqdn;
    webPort = 3001;
    secretKeyBaseFile = config.age.secrets."dawarich/secretKeyBaseFile".path;
    redis.createLocally = true;
    database.createLocally = true;
    # The module defaults to 3, which leaves most of najdorf's 12 cores idle
    # while a history import works through points, tracks and stats.
    sidekiqThreads = 6;
    sidekiqProcesses = {
      all = {
        jobClasses = [ ];
        threads = null;
      };
      geocoding = {
        jobClasses = [ "reverse_geocoding" ];
        threads = geocodingThreads;
      };
    };
    smtp = {
      host = config.vars.smtp.host;
      port = config.vars.smtp.port;
      user = config.vars.smtp.user;
      passwordFile = config.age.secrets.smtpPassword.path;
      fromAddress = "Dawarich <${config.vars.email}>";
    };
    environment = {
      # APPLICATION_PROTOCOL is left at the module's "http" default on purpose:
      # "https" turns on Rails force_ssl, which has no path exclusions and
      # redirects loopback callers to https://localhost:3001, where puma speaks
      # plain HTTP. Tailscale serve terminates TLS and sets X-Forwarded-Proto,
      # so browsers are unaffected, but the Home Assistant integration talks to
      # 127.0.0.1 and would only ever get 301/307s.
      OIDC_CLIENT_ID = oidcClientId;
      OIDC_ISSUER = tsidpUrl;
      OIDC_REDIRECT_URI = oidcRedirectUri;
      OIDC_PROVIDER_NAME = "Tailscale";
      OIDC_AUTO_REGISTER = "true";
      ALLOW_EMAIL_PASSWORD_REGISTRATION = "false";
      ALLOW_EMAIL_PASSWORD_LOGIN = "false";
      PHOTON_API_HOST = "127.0.0.1:${photonPort}";
      PHOTON_API_USE_HTTPS = "false";
      # Photon is local and unmetered, so the default cap of a third of the
      # worker pool only throttles imports. Must match the dedicated
      # reverse_geocoding process below: the queue limit is global and derived
      # from this, not from the -c sidekiq is started with.
      REVERSE_GEOCODING_CONCURRENCY = toString geocodingThreads;
    };
    extraEnvFiles = [
      config.age.secrets."dawarich/oidcClientSecretEnvFile".path
    ];
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.dawarich.https."443" =
  #   "http://localhost:${builtins.toString config.services.dawarich.webPort}";

  virtualisation.arion.projects.photon.settings =
    let
      volume = "photon_data";
    in
    {
      docker-compose.volumes.${volume} = { };
      services.photon.service = {
        image = "rtuszik/photon-docker:2.5.0";
        container_name = "photon";
        network_mode = "host";
        volumes = [ "${volume}:/photon/data" ];
        restart = "unless-stopped";
        environment = {
          UPDATE_INTERVAL = "720h";
          PUID = "0";
          PGID = "0";
          REGION = "planet";
          # Downloads the new index only after deleting the old one. PARALLEL
          # keeps both, which for the planet index means ~103GB of extra peak
          # this disk does not have.
          UPDATE_STRATEGY = "SEQUENTIAL";
          # network_mode is host and the firewall is off, so the default
          # 0.0.0.0 would publish the geocoder on the LAN and the tailnet.
          # Dawarich reaches it over loopback.
          PHOTON_LISTEN_IP = "127.0.0.1";
          # Lucene serves the index through mmap, so page cache does more for
          # lookup latency here than heap does. Capped well under the JVM
          # default of a quarter of RAM to leave that cache to a 14GB host.
          JAVA_PARAMS = "-Xmx2g";
        };
      };
    };
}
