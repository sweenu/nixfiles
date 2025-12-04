{
  self,
  config,
  suites,
  pkgs,
  lib,
  ...
}:

let
  resticRepository = "s3:s3.us-west-001.backblazeb2.com/sweenu-server-restic";
  encryptedRoot = "cryptroot";
  network = {
    matchConfig.Name = "en*";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
      DNSDefaultRoute = true;
    };
    dhcpV4Config = {
      UseDNS = false;
      UseDomains = true;
    };
    domains = [
      "~lan"
      "~local"
      "~bytel.fr" # Bbox
    ];
    dns = [ "192.168.1.254" ];
    linkConfig.RequiredForOnline = "yes";
  };
in
{
  imports = [
    # Services
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
    ./lldap.nix
    ./grist.nix
    ./nocodb.nix
    ./netdata.nix
    ./hass.nix
    ./qgis.nix
    ./cockpit.nix
  ]
  ++ suites.base
  ++ suites.server;

  users.groups.smtp = { };
  age.secrets = {
    smtpPassword = {
      file = "${self}/secrets/smtp_password.age";
      group = "smtp";
      mode = "440";
    };
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "r8152" # for framework eth adapter
      ];
      luks.devices.${encryptedRoot} = {
        allowDiscards = true;
      };
      # Allows decrypting the drive over SSH
      network = {
        enable = true;
        ssh = {
          enable = true;
          hostKeys = [ "/etc/ssh/initrd_ssh_host_ed25519_key" ];
        };
      };
      systemd = {
        enable = true;
        users.root.shell = "/bin/systemd-tty-ask-password-agent";
        network.networks."10-wired" = network;
      };
    };
    kernelPackages = pkgs.linuxPackages_6_17;
    kernelModules = [ "kvm-amd" ];
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  disko = {
    devices = {
      disk.main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                mountpoint = "/boot";
                format = "vfat";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = encryptedRoot;
                content = {
                  type = "filesystem";
                  mountpoint = "/";
                  format = "ext4";
                };
              };
            };
          };
        };
      };
    };
  };

  zramSwap.enable = true;

  environment.defaultPackages = with pkgs; [
    framework-tool
    restic
    redu
    wol
  ];

  users.users."${config.vars.username}".openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];

  time.timeZone = config.vars.timezone;

  systemd.network.networks."10-wired" = network;

  networking.firewall.extraCommands = lib.openTCPPortForLAN 22;

  virtualisation = {
    docker = {
      enable = true;
      daemon.settings.dns = config.vars.dnsResolvers;
    };
    arion.backend = "docker";
  };

  services = {
    avahi.enable = true;
    journald.extraConfig = ''
      SystemMaxUse = 10G;
    '';
    # PostgreSQL config and backups
    postgresql = {
      package = pkgs.postgresql_16;
      settings.log_timezone = config.time.timeZone;
    };
    postgresqlBackup = {
      enable = config.services.postgresql.enable;
      startAt = "*-*-* 03:17:00";
    };
    fstrim.enable = true;
    fwupd.enable = true;
  };

  # Restic backups
  age.secrets = {
    resticPassword.file = "${self}/secrets/restic/password.age";
    resticEnv.file = "${self}/secrets/restic/env.age";
  };
  environment.sessionVariables = {
    RESTIC_PASSWORD_FILE = config.age.secrets.resticPassword.path;
    RESTIC_REPOSITORY = resticRepository;
  };
  services.restic = {
    backups.opt = {
      initialize = true;
      repository = resticRepository;
      environmentFile = config.age.secrets.resticEnv.path;
      paths = [
        "/opt"
      ]
      ++ (
        if config.services.postgresqlBackup.enable then
          [ config.services.postgresqlBackup.location ]
        else
          [ ]
      );
      pruneOpts = [
        "--keep-last 36"
        "--keep-daily 14"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 3"
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
