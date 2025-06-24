{ self
, modulesPath
, config
, suites
, pkgs
, ...
}:

let
  resticRepository = "rest:http://grunfeld:8000/najdorf";
in
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")

      # services
      ./traefik.nix
      ./authelia.nix
      ./portainer.nix
      ./nextcloud.nix
      ./calibre-web.nix
      ./goeland.nix
      ./n8n.nix
      ./immich.nix
      ./obsidian-livesync.nix
      ./obsidian-share-note.nix
      ./ollama.nix
      ./lldap.nix
    ]
    ++ suites.server
    ++ suites.base;

  # Service to uncomment only when commissioning a new server to be able to connect to tailscale unattended. Don't forget to recomment afterwards.
  # Generate the auth key here: https://login.tailscale.com/admin/settings/keys
  # systemd.services.tailscale-login = import "${self}/profiles/ts-oneshot-login.nix" { tailscalePkg = pkgs.tailscale; authKey = ""; }

  users.groups.smtp = { };

  age.secrets.smtpPassword = {
    file = "${self}/secrets/smtp_password.age";
    group = "smtp";
    mode = "440";
  };

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
    kernelPackages = pkgs.linuxPackages_6_12;
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

  # PostgreSQL config and backups
  services.postgresql = {
    package = pkgs.postgresql_15;
  };
  services.postgresqlBackup = {
    enable = config.services.postgresql.enable;
    startAt = "*-*-* 03:17:00";
  };

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
      paths = [
        "/opt"
      ] ++ (if config.services.postgresqlBackup.enable then [ config.services.postgresqlBackup.location ] else [ ]);
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
