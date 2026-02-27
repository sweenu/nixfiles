{ self, config, ... }:

let
  serverUrl = "https://relay-server.${config.vars.tailnetName}";
in
{
  age.secrets = {
    "obsidian-relay/env".file = "${self}/secrets/obsidian-relay/env.age";
  };

  services.relay-server = {
    enable = true;
    environmentFile = config.age.secrets."obsidian-relay/env".path;
    environment = {
      RELAY_SERVER_KEY_ID = config.services.relay-control-plane.environment.RELAY_HMAC_KEY_ID;
    };
    settings = {
      server = {
        url = serverUrl;
        port = 12222;
        valid_issuers = [ config.services.relay-control-plane.environment.RELAY_ISSUER ];
      };
    };
  };

  services.relay-control-plane = {
    enable = true;
    port = 12223;
    environmentFile = config.age.secrets."obsidian-relay/env".path;
    environment = {
      RELAY_HMAC_KEY_ID = "sweenu_2026_02_27";
      RELAY_ISSUER = "sweenu-control-plane";
      RELAY_DEFAULT_PROVIDER_URL = serverUrl;
    };
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services = {
  #   relay-server.https."443" =
  #     "http://localhost:${builtins.toString config.services.relay-server.port}";
  #   relay-control-plane.https."443" =
  #     "http://localhost:${builtins.toString config.services.relay-control-plane.port}";
  # };
}
