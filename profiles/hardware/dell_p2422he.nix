{ config, ... }:

let
  hmConf = config.home-manager.users."${config.vars.username}";
  kanshiSettings = hmConf.services.kanshi.settings;
  undockedProfile = builtins.head (
    builtins.filter (entry: entry ? profile && entry.profile.name == "undocked") kanshiSettings
  );
  undockedOutput = builtins.head undockedProfile.profile.outputs;
in
{
  home-manager.users."${config.vars.username}" = {
    services.kanshi.settings = [
      {
        profile.name = "dell_p2422he";
        profile.outputs = [
          {
            criteria = undockedOutput.criteria;
            scale = undockedOutput.scale;
            status = "enable";
            position = "1920,0";
          }
          {
            criteria = "Dell Inc. DELL P2422HE 3KQS5L3";
            status = "enable";
            position = "0,0";
            mode = "1920x1080";
          }
        ];
      }
    ];
  };
}
