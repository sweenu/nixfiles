{ self, config, ... }:

let
  obsidianLiveSyncDir = "/opt/obsidian-livesync";
in
{
  age.secrets."obsidian-livesync/envFile".file = "${self}/secrets/obsidian-livesync/env.age";

  virtualisation.arion.projects.obsidian-livesync.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.obsidian-livesync.service = {
      image = "couchdb:3";
      container_name = "obsidian-livesync";
      volumes = [
        "${obsidianLiveSyncDir}/data:/opt/couchdb/data"
        "${obsidianLiveSyncDir}/etc:/opt/couchdb/etc/local.d"
      ];
      networks = [ config.services.traefik.staticConfigOptions.providers.docker.network ];
      env_file = [ config.age.secrets."obsidian-livesync/envFile".path ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-obsidian-livesync.service" = "obsidian-livesync";
        "traefik.http.services.obsidian-livesync.loadbalancer.server.port" = "5984";
        "traefik.http.routers.obsidian-livesync.middlewares" = "obsidiancors";
        "traefik.http.middlewares.obsidiancors.headers.accesscontrolallowmethods" = "GET,PUT,POST,HEAD,DELETE";
        "traefik.http.middlewares.obsidiancors.headers.accesscontrolallowheaders" = "accept,authorization,content-type,origin,referer";
        "traefik.http.middlewares.obsidiancors.headers.accesscontrolalloworiginlist" = "app://obsidian.md,capacitor://localhost,http://localhost";
        "traefik.http.middlewares.obsidiancors.headers.accesscontrolmaxage" = "3600";
        "traefik.http.middlewares.obsidiancors.headers.addvaryheader" = "true";
        "traefik.http.middlewares.obsidiancors.headers.accessControlAllowCredentials" = "true";
      };
    };
  };

}
