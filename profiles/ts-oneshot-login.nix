{ tailscalePkg, authKey }:
{
  script = "${tailscalePkg}/bin/tailscale up --ssh --authkey ${authKey}";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "default.target" ];
  serviceConfig = {
    Type = "oneshot";
    User = "root";
  };
}
