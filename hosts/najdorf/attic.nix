{
  self,
  config,
  ...
}:

{
  age.secrets = {
    # Contains ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64
    "atticd/env".file = "${self}/secrets/atticd/env.age";
  };

  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets."atticd/env".path;
    settings = {
      listen = "127.0.0.1:5959";
      api-endpoint = "https://attic.${config.vars.tailnetName}/";
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "30 days";
      };
      # Content-addressed chunking for store-wide dedup.
      chunking = {
        nar-size-threshold = 65536;
        min-size = 16384;
        avg-size = 65536;
        max-size = 262144;
      };
    };
  };
}
