{ pkgs
, config
, suites
, ...
}:
{
  imports = suites.server;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
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

  programs.mosh.enable = true;

  hardware.enableRedistributableFirmware = true;

  time.timeZone = config.vars.timezone;

  system.stateVersion = "24.05";
}
