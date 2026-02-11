{
  self,
  config,
  ...
}:

let
  fqdn = "dawarich.${config.vars.domainName}";
  tsidpUrl = "https://idp.${config.vars.tailnetName}";
  dawarichTsUrl = "https://dawarich.${config.vars.tailnetName}";
  oidcClientId = "924f509529c388c8740c7407492777ea";
  oidcRedirectUri = "${dawarichTsUrl}/users/auth/openid_connect/callback";
in

{
  age.secrets = {
    "dawarich/secretKeyBaseFile".file = "${self}/secrets/dawarich/secret_key_base.age";
    "dawarich/oidcClientSecretEnvFile".file = "${self}/secrets/dawarich/oidc_client_secret_env.age";
    smtpPassword.file = "${self}/secrets/smtp_password.age";
  };

  services.dawarich = {
    enable = true;
    configureNginx = false;
    localDomain = fqdn;
    secretKeyBaseFile = config.age.secrets."dawarich/secretKeyBaseFile".path;
    redis.createLocally = true;
    database.createLocally = true;
    smtp = {
      host = config.vars.smtp.host;
      port = config.vars.smtp.port;
      user = config.vars.smtp.user;
      passwordFile = config.age.secrets.smtpPassword.path;
      fromAddress = "Dawarich <${config.vars.email}>";
    };
    extraConfig = {
      OIDC_CLIENT_ID = oidcClientId;
      OIDC_ISSUER = tsidpUrl;
      OIDC_REDIRECT_URI = oidcRedirectUri;
      OIDC_PROVIDER_NAME = "Tailscale";
      OIDC_AUTO_REGISTER = "false";
      ALLOW_EMAIL_PASSWORD_REGISTRATION = "false";
      PHOTON_API_HOST = "127.0.0.1:2322";
      PHOTON_API_USE_HTTPS = "false";
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
        image = "rtuszik/photon-docker:latest";
        container_name = "photon";
        network_mode = "host";
        volumes = [ "${volume}:/photon/data" ];
        restart = "unless-stopped";
        environment = {
          UPDATE_INTERVAL = "720h";
          PUID = "0";
          PGID = "0";
          REGION = "europe";
        };
      };
    };
}
