{
  self,
  modulesPath,
  config,
  suites,
  pkgs,
  ...
}:

let
  resticRepository = "sftp:root@grunfeld:/data/backups/najdorf";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    # services
    ./traefik
    ./authelia
    ./portainer.nix
    ./nextcloud.nix
    ./calibre-web.nix
    ./simple-torrent.nix
    ./goeland.nix
    ./n8n
    ./obsidian-livesync.nix
    # ./ig-story-fetcher.nix
    ./vrising.nix
    ./vrising-discord-bot.nix
  ] ++ suites.server ++ suites.base;

  # Service to uncomment only when commissioning a new server to be able to connect to tailscale unattended. Don't forget to recomment afterwards.
  # Generate the auth key here: https://login.tailscale.com/admin/settings/keys
  # systemd.services.tailscale-login = import ./tailscale-login.nix { tailscalePkg = pkgs.tailscale; authKey = ""; }

  boot = {
    initrd = {
      kernelModules = [ "nvme" ];
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
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

  environment.defaultPackages = with pkgs; [
    restic
    unison
  ];

  services.journald.extraConfig = ''
    SystemMaxUse = 2G;
  '';

  users.users."${config.vars.username}".openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];

  time.timeZone = config.vars.timezone;

  virtualisation.docker = {
    enable = true;
    daemon.settings.dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
  virtualisation.arion.backend = "docker";

  # Restic backups
  age.secrets.resticPassword.file = "${self}/secrets/restic_password.age";
  environment.sessionVariables = {
    RESTIC_PASSWORD_FILE = config.age.secrets.resticPassword.path;
    RESTIC_REPOSITORY = resticRepository;
  };
  services.restic = {
    backups.opt = {
      initialize = true;
      repository = resticRepository;
      paths = [ "/opt" ];
      pruneOpts = [
        "--keep-last 36"
        "--keep-daily 14"
        "--keep-weekly 12"
      ];
      timerConfig = {
        OnCalendar = "*-*-* *:00:00"; # every hour
        RandomizedDelaySec = "5m";
      };
      passwordFile = config.age.secrets.resticPassword.path;
      backupCleanupCommand = "${pkgs.curl}/bin/curl -m 10 --retry 5 https://hc-ping.com/3e004d53-809a-4386-bb45-a36fc919120a/$EXIT_STATUS";
      exclude = [ "/opt/containerd" ];
    };
  };
}
