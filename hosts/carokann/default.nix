{ config
, suites
, pkgs
, lib
, ...
}:

let
  encryptedRoot = "cryptroot";
in
{
  imports = suites.laptop;

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
    avahi.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    ollama = {
      acceleration = "rocm"; # Enables AMD ROCm GPU + NPU acceleration
      rocmOverrideGfx = "gfx1150"; # Specific target for Ryzen AI 300 iGPU
    };
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
    framework-system-tools
  ];

  home-manager.users."${config.vars.username}" = {
    home.file.".ssh/id_ed25519.pub".text = config.vars.sshPublicKey;

    services.shikane = {
      enable = true;
      settings = {
        profile =
          let
            resWidth = 2256;
            resHeight = 1504;
            laptopOutput = {
              search = "n=eDP-1";
              enable = true;
              mode = {
                width = resWidth;
                height = resHeight;
                refresh = 60;
              };
              scale = 1.6;
            };
          in
          [
            {
              name = "laptop-only";
              output = [ laptopOutput ];
            }
            # Put a default external monitor to the right and assign workspaces u, i, o and p.
            {
              name = "external-output-default";
              output = [
                (laptopOutput // { exec = [ "hyprctl keyword workspace r[1-4],monitor:$SHIKANE_OUTPUT_NAME" ]; })
                {
                  search = "n/(DP-[1-9]|HDMI-[A-C]-[1-9])";
                  enable = true;
                  position = {
                    x = resWidth;
                    y = 0;
                  };
                  mode = "preferred";
                  exec =
                    (map (ws: lib.hyprMoveWsToMonitor ws "$SHIKANE_OUTPUT_NAME") [
                      "u"
                      "i"
                      "o"
                      "p"
                    ])
                    ++ [ "hyprctl keyword workspace r[5-8],monitor:$SHIKANE_OUTPUT_NAME" ];
                }
              ];
            }
            # At home, put laptop monitor on the right and give the main monitor a, s, d and f
            {
              name = "home";
              output = [
                (
                  laptopOutput
                  // {
                    position = {
                      x = 1920;
                      y = 141;
                    }; # Align bottom corners
                    exec =
                      (map (ws: lib.hyprMoveWsToMonitor ws "$SHIKANE_OUTPUT_NAME") [
                        "u"
                        "i"
                        "o"
                        "p"
                      ])
                      ++ [ "hyprctl keyword workspace r[5-8],monitor:$SHIKANE_OUTPUT_NAME" ];
                  }
                )
                {
                  search = [
                    "v=Dell Inc."
                    "m=DELL U2424HE"
                    "s=FF904X3"
                  ];
                  enable = true;
                  position = {
                    x = 0;
                    y = 0;
                  };
                  mode = "1920x1080";
                  exec =
                    (map (ws: lib.hyprMoveWsToMonitor ws "$SHIKANE_OUTPUT_NAME") [
                      "a"
                      "s"
                      "d"
                      "f"
                    ])
                    ++ [ "hyprctl keyword workspace r[1-4],monitor:$SHIKANE_OUTPUT_NAME" ];
                }
              ];
            }
          ];
      };
    };
  };
}
