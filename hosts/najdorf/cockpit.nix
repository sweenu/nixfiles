{ config, ... }:

let
  fqdn = "cockpit.${config.vars.domainName}";
  url = "https://${fqdn}";
in
{
  services.cockpit = {
    enable = true;
    allowed-origins = [ url ];
    port = 12431;
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-cockpit = {
      rule = "Host(`${fqdn}`)";
      service = "cockpit";
      middlewares = "authelia";
    };
    services."${routers.to-cockpit.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString config.services.cockpit.port}";
      }
    ];
  };
}
