{ config, ... }:

let
  fqdn = "opodsync.${config.vars.domainName}";
in
{
  services.opodsync = {
    enable = true;
    port = 9008;
    config = {
      BASE_URL = "https://${fqdn}";
      TITLE = "oPodSync";
      SQLITE_JOURNAL_MODE = "WAL";
    };
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-opodsync = {
      rule = "Host(`${fqdn}`)";
      service = "opodsync";
      # middlewares = "authelia";
    };
    services."${routers.to-opodsync.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${toString config.services.opodsync.port}";
      }
    ];
  };

  services.authelia.instances.main.settings.access_control.rules = [
    {
      domain = fqdn;
      resources = [ "^/api/.*" ];
      policy = "bypass";
    }
  ];
}
