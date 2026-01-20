{
  self,
  lib,
  config,
  pkgs,
  suites,
  ...
}:
{
  imports = suites.base;

  services.getty.autologinUser = config.vars.username;
  users.users."${config.vars.username}" = {
    password = null;
    initialPassword = null;
    hashedPassword = lib.mkForce null;
    initialHashedPassword = "";
  };

  boot.loader.systemd-boot.enable = true;

  environment.defaultPackages = with pkgs; [
    cryptsetup
    nvme-cli
    parted
  ];

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings.PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];

  # Required, but will be overridden in the resulting installer ISO.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
  };

  home-manager.users."${config.vars.username}" = {
    home.file.nixfiles = {
      source = self;
      recursive = true;
    };
  };
}
