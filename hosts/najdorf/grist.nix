{
  self,
  config,
  ...
}:

let
  gristDir = "/opt/grist";
  fqdn = "grist.${config.vars.domainName}";
  gristUrl = "https://${fqdn}";
  oidcClientId = "grist";
  autheliaUrl = "https://authelia.${config.vars.domainName}";
in
{
  age.secrets = {
    "grist/envFile".file = "${self}/secrets/grist/env.age";
    "grist/oidcClientSecretDigest" = {
      file = "${self}/secrets/grist/oidc_client_secret_digest.age";
      owner = config.services.authelia.instances.main.user;
    };
  };

  virtualisation.arion.projects.grist.settings = {
    networks.traefik.external = true;

    services = {
      grist.service = {
        image = "gristlabs/grist:1.6";
        container_name = "grist";
        networks = [
          "default"
          config.services.traefik.staticConfigOptions.providers.docker.network
        ];
        volumes = [
          "${gristDir}:/persist"
        ];
        environment = {
          APP_HOME_URL = gristUrl;
          GRIST_LOG_LEVEL = "warn";
          GRIST_SINGLE_ORG = "grist";
          GRIST_FORCE_LOGIN = "true";
          GRIST_SANDBOX_FLAVOR = "gvisor";
          # OIDC
          GRIST_OIDC_IDP_ISSUER = autheliaUrl;
          GRIST_OIDC_IDP_CLIENT_ID = oidcClientId;
          GRIST_OIDC_IDP_END_SESSION_ENDPOINT = "${autheliaUrl}/logout";
        };
        env_file = [ config.age.secrets."grist/envFile".path ]; # sets GRIST_DEFAULT_EMAIL, GRIST_SESSION_SECRET and GRIST_OIDC_IDP_CLIENT_SECRET
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-grist.service" = "grist";
          "traefik.http.services.grist.loadbalancer.server.port" = "8484";
          "traefik.http.routers.to-grist.middlewares" = "authelia@file";
        };
      };
    };
  };

  services.authelia.instances.main.settings.identity_providers.oidc.clients = [
    {
      client_id = oidcClientId;
      client_name = "Grist";
      client_secret = ''{{ secret "${config.age.secrets."grist/oidcClientSecretDigest".path}" }}'';
      scopes = [
        "openid"
        "groups"
        "email"
        "profile"
      ];
      authorization_policy = "one_factor";
      redirect_uris = [ "${gristUrl}/oauth2/callback" ];
      pre_configured_consent_duration = "1y";
    }
  ];
}
