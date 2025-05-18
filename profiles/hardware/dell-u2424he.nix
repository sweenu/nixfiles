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
        profile.name = "dell_u2424he";
        profile.outputs = [
          {
            criteria = undockedOutput.criteria;
            scale = undockedOutput.scale;
            status = "enable";
            position = "1920,77";
          }
          {
            criteria = "Dell Inc. DELL U2424HE FF904X3";
            status = "enable";
            position = "0,0";
            mode = "1920x1080";
          }
        ];
      }
    ];
  };
}
