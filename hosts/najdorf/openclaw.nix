{ config, ... }:

let
  openclawDir = "/opt/openclaw";
  port = 18789;
  # OpenClaw's container runs as the unprivileged `node` user (uid/gid 1000),
  # so the bind-mounted state directories must be owned by it.
  uid = "1000";
  gid = "1000";
in
{
  # Persistent state, owned by the container's `node` user.
  # - config:  /home/node/.openclaw        (config, agents, auth profiles, workspace)
  # - secrets: /home/node/.config/openclaw (auth-profile encryption key)
  systemd.tmpfiles.rules = [
    "d ${openclawDir}         0750 ${uid} ${gid} - -"
    "d ${openclawDir}/config  0750 ${uid} ${gid} - -"
    "d ${openclawDir}/secrets 0700 ${uid} ${gid} - -"
  ];

  virtualisation.arion.projects.openclaw.settings = {
    services.openclaw.service = {
      # `-browser` variant bundles Chromium if you need browser tooling.
      image = "ghcr.io/openclaw/openclaw:latest";
      container_name = "openclaw";
      restart = "unless-stopped";
      volumes = [
        "${openclawDir}/config:/home/node/.openclaw"
        "${openclawDir}/secrets:/home/node/.config/openclaw"
      ];
      # Bind to loopback only; exposure is handled via Tailscale (see below).
      ports = [ "127.0.0.1:${toString port}:${toString port}" ];
      environment = {
        OPENCLAW_TZ = config.vars.timezone;
        # No mDNS discovery inside the container.
        OPENCLAW_DISABLE_BONJOUR = "1";
      };
    };
  };

  # Uses a Claude subscription rather than an API key. After the first deploy,
  # register a Claude Code setup-token (generated with `claude setup-token`):
  #   docker exec -it openclaw openclaw models auth paste-token --provider anthropic
  # Setup-tokens (sk-ant-oat...) are static and must be re-pasted when they expire.

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.openclaw.https."443" =
  #   "http://localhost:${toString port}";
}
