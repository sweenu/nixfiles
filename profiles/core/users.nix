{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword = "$y$j9T$jMx/XkaWfgV1bsRBjgmvd1$rDi8pFUskXUjlyhJefMZDYp6VwFy.zACp3wVtI7g.IA";
      "${config.vars.username}" = {
        shell = pkgs.fish;
        hashedPassword = "$y$j9T$ZjVM7P34OZjC8/o5LI5N7/$nFGR9tfv6TDeIrf7FZ.o5Kb.WJuewOB6THeNBIuY44/";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "dialout"
          "input" # for evdev manager integration with shell
        ]
        ++ pkgs.lib.optional config.virtualisation.libvirtd.enable "libvirtd"
        ++ pkgs.lib.optional config.networking.networkmanager.enable "networkmanager"
        ++ pkgs.lib.optional config.security.tpm2.enable "tss"
        ++ pkgs.lib.optional config.hardware.i2c.enable config.hardware.i2c.group;
      };
    };
  };
}
