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
    ./goeland.nix
    ./n8n
    ./ig-story-fetcher.nix
    ./minecraft
  ] ++ suites.server ++ suites.base;

  boot = {
    loader.grub.device = "/dev/sda";
    initrd = {
      kernelModules = [ "nvme" ];
      availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    };
    kernelPackages = pkgs.linuxPackages_5_10;
  };

  fileSystems = {
    "/" = { device = "/dev/disk/by-uuid/210d49bd-31f9-45fe-bf0f-eddf87375335"; fsType = "ext4"; };
    "/boot" = { device = "/dev/disk/by-uuid/88492e50-02a4-4a00-bf63-07b3b3e979a9"; fsType = "ext4"; };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/73dfbe1b-577d-4fee-b455-5d6366a3c311"; }];

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

  zramSwap.enable = false;
}
