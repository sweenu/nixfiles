{
  self,
  config,
  ...
}:

let
  fqdn = "actual.${config.vars.tailnetName}";
  tsidpUrl = "https://idp.${config.vars.tailnetName}";
  oidcClientId = "5c438a4c4bdf08d932fd17b03dc21ac1";
  port = 5006;
  credName = "oidcClientSecret";
in
{
  age.secrets."actual/oidcClientSecret".file = "${self}/secrets/actual/oidc_client_secret.age";

  services.actual = {
    enable = true;
    settings = {
      hostname = "127.0.0.1";
      inherit port;
      loginMethod = "openid";
      openId = {
        discoveryURL = "${tsidpUrl}/.well-known/openid-configuration";
        client_id = oidcClientId;
        client_secret._secret = "/run/credentials/actual.service/${credName}";
        server_hostname = "https://${fqdn}";
      };
    };
  };

  systemd.services.actual.serviceConfig.LoadCredential = [
    "${credName}:${config.age.secrets."actual/oidcClientSecret".path}"
  ];

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.actual.https."443" =
  #   "http://localhost:${builtins.toString config.services.actual.settings.port}";
}
