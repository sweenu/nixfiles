{ pkgs
, config
, suites
, ...
}:
{
  imports = suites.server ++ [
    ./snapserver.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/87d6b688-bd27-4466-8824-5d559f6115ec";
      fsType = "ext4";
      options = [
        "nofail"
        "X-mount.mkdir"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    kakoune
    git
    curl
    bottom
    wol
  ];

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
        {
          address = config.vars.grunfeldIPv4;
          prefixLength = 24;
        }
      ];
      useDHCP = false;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      userServices = true;
    };
  };
  services.restic.server = {
    enable = true;
    dataDir = "/data/backups/";
    extraFlags = [ "--no-auth" ];
  };

  hardware.enableRedistributableFirmware = true;

  time.timeZone = config.vars.timezone;

  system.stateVersion = "24.05";
}
