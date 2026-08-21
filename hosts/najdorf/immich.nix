{
  self,
  config,
  ...
}:

let
  fqdn = "immich.${config.vars.domainName}";
in
{
  age.secrets = {
    "immich/envFile".file = "${self}/secrets/immich/env.age";
  };

  services.immich = {
    enable = true;
    environment = {
      TZ = config.vars.timezone;
    };
    machine-learning = {
      enable = true;
    };
    secretsFile = config.age.secrets."immich/envFile".path;
    mediaLocation = "/opt/immich";
    port = 2283;
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-immich = {
      # Shared links need the SvelteKit bundle and the API on top of /share.
      # The web UI root stays unrouted so the login page isn't publicly reachable.
      rule = "Host(`${fqdn}`) && (PathPrefix(`/share`) || PathPrefix(`/_app`) || PathPrefix(`/api`) || PathRegexp(`^/(custom\\.css|favicon.*|apple-icon.*)$`))";
      service = "immich";
    };
    services."${routers.to-immich.service}".loadBalancer.servers = [
      {
        url = "http://localhost:${builtins.toString config.services.immich.port}";
      }
    ];
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.immich.https."443" =
  #   "http://localhost:${builtins.toString config.services.immich.port}";
}
