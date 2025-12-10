{
  config,
  suites,
  pkgs,
  ...
}:

let
  encryptedRoot = "cryptroot";
in
{
  imports = suites.laptop ++ [
    ./shikane.nix
  ];

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
  services.fstrim.enable = true;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "tpm_tis" # TPM2 kernel module
      ];
      systemd = {
        enable = true;
        tpm2.enable = true;
      };
      luks.devices.${encryptedRoot} = {
        allowDiscards = true;
        bypassWorkqueues = true;
        crypttabExtraOpts = [ "tpm2-device=auto" ]; # Use TPM2 to unlock
      };
    };
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 1024 * 32;
    }
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    sane.enable = true;
    graphics.enable = true;
    i2c.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
    tailscale.useRoutingFeatures = "client";
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  time.timeZone = config.vars.timezone;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  age.identityPaths = [ "${config.vars.home}/.ssh/id_ed25519" ];

  environment.defaultPackages = with pkgs; [
    framework-tool
  ];

  services.pipewire.wireplumber.extraConfig = {
    "5-built-in-speakers-rename" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "alsa_output.pci-0000_c1_00.6.HiFi__Speaker__sink"; } ];
          actions = {
            update-props = {
              "node.nick" = "Built-in Speakers";
            };
          };
        }
      ];
    };
    # See https://github.com/NixOS/nixos-hardware/issues/1603
    "no-ucm" = {
      "monitor.alsa.properties" = {
        "alsa.use-ucm" = false;
      };
    };
  };

  home-manager.users."${config.vars.username}" = {
    home.file.".ssh/id_ed25519.pub".text = config.vars.sshPublicKey;
  };
}
