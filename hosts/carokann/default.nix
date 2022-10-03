{ config, suites, pkgs, ... }:

{
  imports = suites.laptop;

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "sd_mod" ];
      luks.devices."cryptroot".device = "/dev/disk/by-uuid/db2abb19-d9d5-4cf6-b27f-02ed9bc8b63a";
    };
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/50d06182-1747-42e1-88fa-cadca977e46b";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/EC81-FE28";
      fsType = "vfat";
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    sane.enable = true;
    opengl.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    avahi.enable = true;
    fwupd.enable = true;
  };

  time.timeZone = "Europe/Paris";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  age.identityPaths = [ "${config.vars.home}/.ssh/id_ed25519" ];

  home-manager.users."${config.vars.username}" = {
    home.file.".ssh/id_ed25519.pub".text = config.vars.sshPublicKey;
    services.kanshi.profiles = {
      undocked.outputs = [
        {
          criteria = "eDP-1";
          status = "enable";
          scale = 1.5;
          position = "0,0";
        }
      ];
    };
    services.unison = {
      enable = true;
      pairs.calibre.roots = [
        "${config.vars.home}/books"
        "ssh://root@benoni//opt/calibre/data"
      ];
    };
  };
}
