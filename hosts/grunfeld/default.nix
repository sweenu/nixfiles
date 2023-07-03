{ lib, pkgs, config, suites, ... }:
let
  najdorfRootKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPpe019oujhjgqS0Xif2soaQpxJiZSrMr9rhmII958qU root@najdorf'';
in
{
  imports = suites.server ++ [ ./snapserver.nix ./3proxy.nix ];

  boot = {
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
      };
      generic-extlinux-compatible.enable = lib.mkForce false; # incompatible with raspberryPi.enable = true
    };
    kernelParams = [ "cma=32M" ];
    kernelPackages = pkgs.linuxPackages_5_10;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/87d6b688-bd27-4466-8824-5d559f6115ec";
      fsType = "ext4";
      options = [ "nofail" "X-mount.mkdir" ];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
      options = [ "nofail" ];
    }
  ];

  environment.systemPackages = with pkgs; [ kakoune git curl bottom ];

  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M;
  '';

  networking = {
    useDHCP = false;
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    nameservers = [ "1.1.1.1" ];
    interfaces.eth0 = {
      ipv4.addresses = [
        { address = config.vars.grunfeldIPv4; prefixLength = 24; }
      ];
      useDHCP = false;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [ najdorfRootKey ];

  hardware.enableRedistributableFirmware = true;

  time.timeZone = config.vars.timezone;

  system.stateVersion = "22.11";
}
