{ self, config, ... }:

let
  fqdn = "n8n.${config.vars.domainName}";
  url = "https://${fqdn}";
in
{
  age.secrets.n8nEncryptionKey.file = "${self}/secrets/n8n/encryption_key.age";

  services.n8n = {
    enable = true;
    environment = {
      WEBHOOK_URL = url;
      N8N_ENCRYPTION_KEY_FILE = "%d/encryption_key";
      N8N_PERSONALIZATION_ENABLED = "false";
      N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
      N8N_HIRING_BANNER_ENABLED = "false";
      N8N_DIAGNOSTICS_ENABLED = "false";
    };
  };

  systemd.services.n8n.serviceConfig.LoadCredential = [
    "encryption_key:${config.age.secrets.n8nEncryptionKey.path}"
  ];

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-n8n = {
      rule = "Host(`${fqdn}`)";
      service = "n8n";
      middlewares = "authelia";
    };
    services."${routers.to-n8n.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString config.services.n8n.environment.N8N_PORT}";
      }
    ];
  };

  services.authelia.instances.main.settings.access_control.rules = [
    {
      domain = fqdn;
      resources = [ "^/webhook(-test)?/.*" ];
      methods = [
        "GET"
        "POST"
      ];
      policy = "bypass";
    }
    {
      domain = fqdn;
      resources = [ "^/form/.*" ];
      methods = [
        "GET"
        "POST"
      ];
      policy = "bypass";
    }
  ];
}
