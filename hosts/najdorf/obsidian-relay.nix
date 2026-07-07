{ self, config, ... }:

let
  serverUrl = "https://relay-server.${config.vars.tailnetName}";
  signingKeyId = "sweenu_ed25519_2026_07_08";
  publicKey = "PTNV6+uFG/ArYwfjVjEyzocZB/JV00NC4SdKcFoyBNQ=";
in
{
  age.secrets = {
    "obsidian-relay/env".file = "${self}/secrets/obsidian-relay/env.age";
  };

  services.relay-server = {
    enable = true;
    environment = {
      RUST_LOG = "warn";
    };
    settings = {
      server = {
        url = serverUrl;
        port = 12222;
        valid_issuers = [ config.services.relay-control-plane.environment.RELAY_ISSUER ];
      };
      auth = [
        {
          key_id = signingKeyId;
          public_key = publicKey;
        }
      ];
    };
  };

  services.relay-control-plane = {
    enable = true;
    port = 12223;
    environmentFile = config.age.secrets."obsidian-relay/env".path;
    environment = {
      RELAY_SIGNING_KEY_ID = signingKeyId;
      RELAY_ISSUER = "sweenu-relay-control-plane";
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
