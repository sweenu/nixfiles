{
  self,
  inputs,
  config,
  pkgs,
  ...
}:

let
  fqdn = "pretix.${config.vars.domainName}";
  url = "https://${fqdn}";
  port = 9822;
in
{
  age.secrets."pretix/env".file = "${self}/secrets/pretix/env.age";

  services.pretix = {
    enable = true;
    database.createLocally = true;
    environmentFile = config.age.secrets."pretix/env".path;
    nginx = {
      enable = true;
      domain = fqdn;
    };

    plugins = [
      inputs.pretix-postfinance.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    settings = {
      pretix = {
        instance_name = fqdn;
        url = url;
        currency = "EUR";
        registration = false;
      };
      mail = {
        from = config.vars.email;
        host = config.vars.smtp.host;
        user = config.vars.smtp.user;
        port = config.vars.smtp.port;
        ssl = true;
      };
    };
  };

  services.nginx.virtualHosts.${fqdn} = {
    listen = [
      {
        addr = "127.0.0.1";
        port = port;
      }
      {
        addr = "[::1]";
        port = port;
      }
    ];
    enableACME = false;
    forceSSL = false;
    onlySSL = false;
    addSSL = false;
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-pretix = {
      rule = "Host(`${fqdn}`)";
      service = "pretix";
    };

    services."${routers.to-pretix.service}".loadBalancer.servers = [
      {
        url = "http://localhost:${builtins.toString port}";
      }
    ];
  };
}
