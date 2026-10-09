{ ... }:

let
  port = 18789;
in
{
  services.openclaw-gateway = {
    enable = true;
    inherit port;
    config = {
      # localhost only; exposure is handled via Tailscale (see below).
      # najdorf runs without a host firewall, so keep this on loopback.
      gateway.bind = "loopback";
    };
  };

  # Uses a Claude subscription rather than an API key. After the first deploy,
  # register a Claude Code setup-token (generated with `claude setup-token`) as
  # the gateway's `openclaw` service user (matching the service's state dir):
  #   sudo -u openclaw OPENCLAW_STATE_DIR=/var/lib/openclaw \
  #     openclaw models auth paste-token --provider anthropic
  # Setup-tokens (sk-ant-oat...) are static and must be re-pasted when they expire.

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.openclaw.https."443" =
  #   "http://localhost:${toString port}";
}
