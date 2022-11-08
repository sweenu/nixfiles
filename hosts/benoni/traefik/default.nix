{ self, config, pkgs, ... }:

let
  traefikDir = "/opt/traefik";
  acmeDirInContainer = "/etc/traefik/acme";
  networkName = "traefik";
  traefikConfig = pkgs.substituteAll {
    src = ./traefik.yml;
    inherit (config.vars) email domainName;
    inherit acmeDirInContainer networkName;
  };
in
{
  age.secrets = {
    traefikEnvFile.file = "${self}/secrets/traefik/env.age";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  virtualisation.arion.projects.traefik.settings = {
    networks.traefik.name = networkName;
    services.traefik.service = {
      image = "traefik:2.9";
      container_name = "traefik";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "${traefikConfig}:/etc/traefik/traefik.yml:ro"
        "${traefikDir}/acme:${acmeDirInContainer}"
      ];
      env_file = [ config.age.secrets.traefikEnvFile.path ];
      ports = [
        "80:80"
        "443:443"
      ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-api.service" = "api@internal";
        "traefik.http.routers.to-api.middlewares" = "authelia@docker";
        "traefik.http.middlewares.hsts-header.headers.customresponseheaders.Strict-Transport-Security" = "max-age=63072000";
      };
    };
  };
}
