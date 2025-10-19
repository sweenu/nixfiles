{ config, ... }:

let
  qgisDir = "/opt/qgis";
  qgisDataDir = "${qgisDir}/data";
  qgisProjectsDir = "${qgisDir}/projects";
in
{
  virtualisation.arion.projects.qgis-server.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.qgis.service = {
      image = "qgis/qgis-server:latest";
      container_name = "qgis";
      volumes = [
        "${qgisProjectsDir}:/projects"
        "${qgisDataDir}:/data"
      ];
      networks = [ config.services.traefik.staticConfigOptions.providers.docker.network ];
      environment = {
        TZ = config.vars.timezone;
        QGIS_SERVER_LOG_LEVEL = "0";
        QGIS_SERVER_LOG_STDERR = "1";
        QGIS_PROJECT_FILE = "/projects";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-qgis.middlewares" = "authelia-basic@file";
      };
    };
  };
}
