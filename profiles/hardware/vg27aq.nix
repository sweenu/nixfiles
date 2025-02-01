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
        profile.name = "asus_vg27aq";
        profile.outputs = [
          {
            criteria = undockedOutput.criteria;
            scale = undockedOutput.scale;
            status = "enable";
            position = "2560,0";
          }
          {
            criteria = "ASUSTek COMPUTER INC VG27A RBLMQS030515";
            status = "enable";
            position = "0,0";
            mode = "2560x1440";
            adaptiveSync = true;
          }
        ];
      }
    ];
  };
}
