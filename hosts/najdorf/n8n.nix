{ self, config, ... }:

let
  n8nDir = "/opt/n8n";
in
{
  age.secrets."n8n/envFile".file = "${self}/secrets/n8n/env.age";

  virtualisation.arion.projects.n8n.settings = {
    enableDefaultNetwork = false;
    networks.traefik.external = true;
    networks.ollama.external = true;
    services.n8n.service = {
      image = "n8nio/n8n:1.84.0";
      container_name = "n8n";
      environment = rec {
        N8N_HIRING_BANNER_ENABLED = "false";
        N8N_PERSONALIZATION_ENABLED = "false";
        WEBHOOK_URL = "https://n8n.${config.vars.domainName}/";
        GENERIC_TIMEZONE = config.vars.timezone;
        TZ = GENERIC_TIMEZONE;
      };
      # sets N8N_ENCRYPTION_KEY=*****
      env_file = [ config.age.secrets."n8n/envFile".path ];
      volumes = [
        # you'll need to `chown -R 1000:1000 /opt/n8n`
        "${n8nDir}:/home/node/.n8n"
      ];
      networks = [ config.services.traefik.staticConfigOptions.providers.docker.network "ollama" ];
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.to-n8n.service" = "n8n";
        "traefik.http.routers.to-n8n.middlewares" = "authelia@docker";
        "traefik.http.services.n8n.loadbalancer.server.port" = "5678";
      };
    };
  };
}
