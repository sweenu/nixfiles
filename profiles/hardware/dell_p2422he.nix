{ config, ... }:

let
  hmConf = config.home-manager.users."${config.vars.username}";
  kanshiProfile = hmConf.services.kanshi.profiles;
in
{
  home-manager.users."${config.vars.username}" = {
    services.kanshi.profiles.dell_p2422he.outputs = let undockedOutput = builtins.head kanshiProfile.undocked.outputs; in [
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
  };
}
