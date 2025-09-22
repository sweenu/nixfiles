{ config, pkgs, ... }:

{
  services.netdata = {
    enable = true;
    package = pkgs.netdata.override {
      withCloudUi = true;
    };
    python = {
      recommendedPythonPackages = true;
    };
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-netdata = {
      rule = "Host(`netdata.${config.vars.domainName}`)";
      service = "netdata";
      middlewares = [ "authelia@file" ];
    };
    services."${routers.to-netdata.service}".loadBalancer.servers = [
      {
        url = "http://localhost:19999";
      }
    ];
  };
}
