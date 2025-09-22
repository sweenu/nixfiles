{ lib, ... }:

let
  nocodbDir = "/opt/nocodb";
  basePort = 8080;
  exposedPort = 12876;
in
{
  virtualisation.arion.projects.nocodb.settings = {
    services = {
      nocodb.service = {
        image = "nocodb/nocodb:0.264.8";
        ports = [ "${builtins.toString exposedPort}:${builtins.toString basePort}" ];
        container_name = "nocodb";
        networks = [ "default" ];
        volumes = [ "${nocodbDir}:/usr/app/data" ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.to-nocodb.service" = "nocodb";
          "traefik.http.routers.to-nocodb.middlewares" = "authelia@file";
          "traefik.http.services.nocodb.loadbalancer.server.port" = builtins.toString basePort;
        };
      };
    };
  };
}
