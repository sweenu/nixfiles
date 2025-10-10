{ self, config, ... }:

let
  fqdn = "notes.${config.vars.domainName}";
  obsidianShareNoteDir = "/opt/obsidian-share-note";
in
{

  age.secrets."obsidian-share-note/envFile".file = "${self}/secrets/obsidian-share-note/env.age";

  virtualisation.arion.projects.obsidian-share-note.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    services.obsidian-share-note.service = {
      image = "ghcr.io/note-sx/server:latest";
      container_name = "obsidian-share-note";
      volumes = [
        "${obsidianShareNoteDir}:/notesx/db:Z"
        "${obsidianShareNoteDir}:/notesx/userfiles:Z"
      ];
      networks = [ config.services.traefik.staticConfigOptions.providers.docker.network ];
      environment = {
        BASE_WEB_URL = "https://${fqdn}";
      };
      env_file = [ config.age.secrets."obsidian-share-note/envFile".path ];
      healthcheck = {
        test = [
          "CMD-SHELL"
          "(wget -qO - http://localhost:3000/v1/ping | grep -q ok) || exit 1"
        ];
        interval = "30s";
        timeout = "5s";
        retries = 2;
        start_period = "10s";
      };
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-obsidian-share-note.rule" = "Host(`${fqdn}`)";
        "traefik.http.routers.to-obsidian-share-note.service" = "obsidian-share-note";
        "traefik.http.services.obsidian-share-note.loadbalancer.server.port" = "3000";
      };
    };
  };

}
