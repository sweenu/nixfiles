{ config, ... }:

let
  url = "https://cockpit.${config.vars.tailnetName}";
in
{
  services.cockpit = {
    enable = true;
    allowed-origins = [ url ];
    port = 12431;
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.cockpit.https."443" = "http://localhost:${builtins.toString config.services.cockpit.port}";
}
