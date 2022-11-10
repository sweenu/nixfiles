{ self, modulesPath, config, suites, pkgs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    # services
    ./traefik
    ./authelia
    ./nextcloud.nix
    ./calibre-web.nix
    ./simple-torrent.nix
    ./searx
    ./goeland.nix
    ./n8n
  ] ++ suites.server ++ suites.base;

  boot = {
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd.kernelModules = [ "nvme" ];
    kernelPackages = pkgs.linuxPackages_5_10;
  };

  fileSystems = {
    "/" = { device = "/dev/vda1"; fsType = "ext4"; };
    "/boot" = { device = "/dev/disk/by-uuid/591D-B8EA"; fsType = "vfat"; };
    "/opt" = { device = "/dev/disk/by-uuid/01a1dc15-ffeb-4237-805c-4b3bc1784738"; fsType = "ext4"; };
  };

  age.secrets.sshPrivateKey = {
    file = "${self}/secrets/benoni_root_key.age";
    path = "/root/.ssh/id_ed25519";
    mode = "600";
  };

  environment.defaultPackages = with pkgs; [ restic unison ];

  services.journald.extraConfig = ''
    SystemMaxUse = 2G;
  '';

  users.users."${config.vars.username}".openssh.authorizedKeys.keys = [
    config.vars.sshPublicKey
  ];

  time.timeZone = config.vars.timezone;

  virtualisation.docker.enable = true;
  virtualisation.arion.backend = "docker";

  zramSwap.enable = true;
}
