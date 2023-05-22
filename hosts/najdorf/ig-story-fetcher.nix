{ self, config, ... }:

{
  age.secrets.IGStoryFetcher.file = "${self}/secrets/ig_story_fetcher_config.age";

  services.ig-story-fetcher = {
    enable = true;
    schedule = "08:00:00";
    randomizedDelaySec = "1h";
    persistent = true;
    settingsPath = config.age.secrets.IGStoryFetcher.path;
  };
}
