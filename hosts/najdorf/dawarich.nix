{
  self,
  config,
  ...
}:

let
  fqdn = "dawarich.${config.vars.domainName}";
  url = "https://${fqdn}";
  autheliaUrl = "https://authelia.${config.vars.domainName}";
  oidcClientId = "dawarich";
  oidcRedirectUri = "${url}/users/auth/openid_connect/callback";
in

{
  age.secrets = {
    "dawarich/secretKeyBaseFile".file = "${self}/secrets/dawarich/secret_key_base.age";
    "dawarich/oidcClientSecretEnvFile".file = "${self}/secrets/dawarich/oidc_client_secret_env.age";
    "dawarich/oidcClientSecretDigest" = {
      file = "${self}/secrets/dawarich/oidc_client_secret_digest.age";
      owner = config.services.authelia.instances.main.user;
    };
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
      OIDC_ISSUER = autheliaUrl;
      OIDC_REDIRECT_URI = oidcRedirectUri;
      OIDC_PROVIDER_NAME = "Authelia";
      OIDC_AUTO_REGISTER = "false";
      ALLOW_EMAIL_PASSWORD_REGISTRATION = "false";
    };
    extraEnvFiles = [
      config.age.secrets."dawarich/oidcClientSecretEnvFile".path
    ];
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-dawarich = {
      rule = "Host(`${fqdn}`)";
      service = "dawarich";
      middlewares = [ "authelia" ];
    };
    services."${routers.to-dawarich.service}".loadBalancer.servers = [
      {
        url = "http://localhost:${builtins.toString config.services.dawarich.webPort}";
      }
    ];
  };

  services.authelia.instances.main.settings = {
    identity_providers.oidc.clients = [
      {
        client_id = oidcClientId;
        client_name = "Dawarich";
        client_secret = ''{{ secret "${config.age.secrets."dawarich/oidcClientSecretDigest".path}" }}'';
        scopes = [
          "openid"
          "groups"
          "email"
          "profile"
        ];
        authorization_policy = "one_factor";
        redirect_uris = [ oidcRedirectUri ];
        pre_configured_consent_duration = "1y";
      }
    ];

    access_control.rules = [
      {
        domain = fqdn;
        resources = [ "^/api/.*" ];
        policy = "bypass";
      }
    ];
  };
}
