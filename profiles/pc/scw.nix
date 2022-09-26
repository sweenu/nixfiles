# TODO: make module
{ self, config, pkgs, ... }:

{
  age.secrets.scwConf = {
    file = "${self}/secrets/scw_conf.age";
    path = "${config.vars.configHome}/scw/config.yaml";
    owner = "${config.vars.username}";
  };

  home-manager.users."${config.vars.username}" = {
    home.packages = [ pkgs.scaleway-cli ];
  };
}
