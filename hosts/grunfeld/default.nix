{ pkgs, config, profiles, ... }:
let
  carokannKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann'';
  benoniSystemKey = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL0bFwpJXdt7vxT82aeMZhfwF5i0DEXaWT3SH2TzxIX root@benoni'';
  ipv4 = "192.168.0.24";
in
{
  imports = [ profiles.vars ];

  boot = {
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
      };
    };
    kernelParams = [ "cma=32M" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/87d6b688-bd27-4466-8824-5d559f6115ec";
      fsType = "ext4";
    };
  };

  environment.systemPackages = with pkgs; [ kakoune git curl bottom ];

  documentation.enable = false;

  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M;
  '';

  networking.firewall.enable = false;

  networking = {
    useDHCP = false;
    defaultGateway = {
      address = "192.168.0.1";
      interface = "eth0";
    };
    nameservers = [ "1.1.1.1" ];
    interfaces.eth0 = {
      ipv4.addresses = [
        { address = ipv4; prefixLength = 24; }
      ];
      useDHCP = false;
    };
  };

  programs.mosh.enable = true;

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

  services.snapserver = {
    enable = true;
    openFirewall = true;
    http = {
      enable = true;
      listenAddress = "0.0.0.0";
      docRoot = "${pkgs.snapcast}/share/snapserver/snapweb/";
    };
    streams = {
      Spotify = {
        type = "librespot";
        location = "${pkgs.librespot}/bin/librespot";
        query = {
          username = config.vars.email;
          password = ""; # has to be set before deploying...
          devicename = "Snapcast";
          normalize = "true";
          autoplay = "false";
          cache = "/home/nixos/.cache/librespot";
          killall = "true";
          params = "--cache-size-limit=4G";
        };
      };
    };
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [ carokannKey benoniSystemKey ];

  swapDevices = [
    { device = "/swapfile"; size = 1024; }
  ];

  hardware.enableRedistributableFirmware = true;

  time.timeZone = "Europe/Paris";

  system.stateVersion = "22.11";
}
