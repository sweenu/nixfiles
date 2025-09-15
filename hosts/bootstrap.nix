{ self, config, pkgs, suites, ... }:
{
  imports = suites.base;

  boot.loader.systemd-boot.enable = true;

  environment.defaultPackages = with pkgs; [
    cryptsetup
    nvme-cli
    parted
  ];

  networking.wireless.enable = false;

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings.PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];

  # Required, but will be overridden in the resulting installer ISO.
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };

  home-manager.users."${config.vars.username}" = {
    home.file.nixfiles = {
      source = self;
      recursive = true;
    };
  };
}
