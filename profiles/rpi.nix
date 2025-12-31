{
  lib,
  ...
}:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  networking.useDHCP = true;

  services = {
    journald.extraConfig = ''
      Storage = volatile
      RuntimeMaxFileSize = 10M;
    '';
  };
}
