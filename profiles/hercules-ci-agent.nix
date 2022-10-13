{ self, config, ... }:
{
  age.secrets = {
    binaryCacheJSON = {
      file = "${self}/secrets/hercules-ci/binary-caches.json.age";
      path = config.services.hercules-ci-agent.settings.binaryCachesPath;
      owner = "hercules-ci-agent";
      group = "hercules-ci-agent";
    };
    clusterJoinToken = {
      file = "${self}/secrets/hercules-ci/cluster-join-token.key.age";
      path = config.services.hercules-ci-agent.settings.clusterJoinTokenPath;
      owner = "hercules-ci-agent";
      group = "hercules-ci-agent";
    };
  };
  services.hercules-ci-agent = {
    enable = true;
  };
}
