{ config, suites, ... }:

{
  imports = suites.base;

  wsl = {
    enable = true;
  };

  services = {
    avahi.enable = true;
    fprintd.enable = true;
  };

  time.timeZone = config.vars.timezone;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  age.identityPaths = [ "${config.vars.home}/.ssh/id_ed25519" ];

  home-manager.users."${config.vars.username}" = {
    home.file.".ssh/id_ed25519.pub".text = config.vars.sshPublicKey;

    # services.unison = {
    #   enable = true;
    #   pairs.calibre.roots = [
    #     "${config.vars.home}/books"
    #     "ssh://root@najdorf//opt/calibre/data"
    #   ];
    # };
  };
}
