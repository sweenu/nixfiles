{ self, config, ... }:

let
  fqdn = "n8n.${config.vars.domainName}";
  url = "https://${fqdn}";
in
{
  age.secrets.n8nEncryptionKey.file = "${self}/secrets/n8n/encryption_key.age";

  services.n8n = {
    enable = true;
    webhookUrl = url;
    settings = {
      hiringBanner.enabled = false;
      personalization.enabled = false;
      generic.timezone = config.vars.timezone;
    };
  };

  systemd.services.n8n.environment.N8N_ENCRYPTION_KEY_FILE = config.age.secrets.n8nEncryptionKey.path;

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-n8n = {
      rule = "Host(`${fqdn}`)";
      service = "n8n";
      middlewares = "authelia";
    };
    services."${routers.to-n8n.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString config.services.n8n.settings.port}";
      }
    ];
  };
}
