{ self, config, pkgs, ... }:

{
  age.secrets.IGStoryFetcher.file = "${self}/secrets/ig_story_fetcher_config.age";

  services.ig-story-fetcher = {
    enable = true;
    schedule = "08:00:00";
    randomizedDelaySec = "1h";
    persistent = true;
    settingsPath = config.age.secrets.IGStoryFetcher.path;
    postStop = "${pkgs.curl}/bin/curl https://hc-ping.com/df3a7e5d-5c19-4fbb-9065-ccf372855efa";
  };
}
