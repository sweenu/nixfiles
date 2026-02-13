{
  self,
  config,
  pkgs,
  ...
}:

let
  publicFqdn = "n8n.${config.vars.domainName}";
  publicUrl = "https://${publicFqdn}";
  fqdn = "n8n.${config.vars.tailnetName}";
  url = "https://${fqdn}";
in
{
  age.secrets = {
    "n8n/encryptionKey".file = "${self}/secrets/n8n/encryption_key.age";
    "n8n/runnersAuthToken".file = "${self}/secrets/n8n/runners_auth_token.age";
  };

  services.n8n = {
    enable = true;
    taskRunners.enable = true;
    customNodes = with pkgs; [
      n8n-nodes-carbonejs
    ];
    environment = {
      WEBHOOK_URL = publicUrl;
      N8N_EDITOR_BASE_URL = url;
      N8N_ENCRYPTION_KEY_FILE = config.age.secrets."n8n/encryptionKey".path;
      N8N_PERSONALIZATION_ENABLED = "false";
      N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
      N8N_HIRING_BANNER_ENABLED = "false";
      N8N_DIAGNOSTICS_ENABLED = "false";
      N8N_RUNNERS_AUTH_TOKEN_FILE = config.age.secrets."n8n/runnersAuthToken".path;
    };
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-n8n = {
      rule = "Host(`${publicFqdn}`) && (PathRegexp(`^/webhook(-test)?/.*`) || PathRegexp(`^/form/.*`))";
      service = "n8n";
    };
    services."${routers.to-n8n.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString config.services.n8n.environment.N8N_PORT}";
      }
    ];
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.n8n.https."443" = "http://localhost:${builtins.toString config.services.n8n.environment.N8N_PORT}";
}
