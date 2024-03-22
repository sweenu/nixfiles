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
    # ./ig-story-fetcher.nix
    ./minecraft
  ] ++ suites.server ++ suites.base;

  # Service to uncomment only when commissioning a new server to be able to connect to tailscale unattended. Don't forget to recomment afterwards.
  # Generate the auth key here: https://login.tailscale.com/admin/settings/keys
  # systemd.services.tailscale-login = import ./tailscale-login.nix { tailscalePkg = pkgs.tailscale; authKey = ""; }

  boot = {
    initrd = {
      kernelModules = [ "nvme" ];
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
    };
    kernelPackages = pkgs.linuxPackages_6_8;
  };

  disko = {
    devices = {
      disk.main = {
        device = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
              priority = 0;
            };
            ESP = {
              type = "EF00";
              size = "512M";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
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

  age.secrets.resticPassword.file = "${self}/secrets/restic_password.age";
  environment.sessionVariables.RESTIC_PASSWORD = "/run/agenix/resticPassword";
}
