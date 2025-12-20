{
  self,
  config,
  suites,
  ...
}:
{
  imports = suites.server ++ [
    "${self}/profiles/core/nix.nix"
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  networking.useDHCP = true;

  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M;
  '';

  services.openssh.openFirewall = true;

  hardware.enableRedistributableFirmware = true;

  time.timeZone = config.vars.timezone;

  system.stateVersion = "26.05";
}
