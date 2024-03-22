{ tailscalePkg, authKey }:
{
  script = "${tailscalePkg}/bin/tailscale up --ssh --authkey ${authKey}";
  serviceConfig = {
    Type = "oneshot";
    User = "root";
  };
}
