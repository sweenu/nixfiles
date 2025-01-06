{ self
, config
, ...
}:

let
  domain = "immich.${config.vars.domainName}";
in
{
  age.secrets = {
    "immich/envFile".file = "${self}/secrets/immich/env.age";
  };

  services.immich = {
    enable = true;
    environment = {
      TZ = config.vars.timezone;
    };
    machine-learning = {
      enable = true;
    };
    secretsFile = config.age.secrets."immich/envFile".path;
    mediaLocation = "/opt/immich";
    port = 2283;
    settings = null;
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-immich = {
      rule = "Host(`${domain}`)";
      service = "immich";
    };
    services."${routers.to-immich.service}".loadBalancer.servers = [
      {
        url = "http://localhost:${builtins.toString config.services.immich.port}";
      }
    ];
  };
}
