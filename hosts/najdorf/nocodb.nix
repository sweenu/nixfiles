{ self
, config
, ...
}:

let
  nocodbDir = "/opt/nocodb";
in
{
  virtualisation.arion.projects.nocodb.settings = {
    services = {
      nocodb.service = {
        image = "nocodblabs/nocodb:0.264.8";
        container_name = "nocodb";
        networks = [ "default" ];
        volumes = [ "${nocodbDir}:/usr/app/data" ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-nocodb.service" = "nocodb";
          "traefik.http.routers.to-nocodb.middlewares" = "authelia@file";
          "traefik.http.services.nocodb.loadbalancer.server.port" = "8080";
        };
      };
    };
  };
}
