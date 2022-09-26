{ config, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword = "$6$EL4ATFe.5R6PMnR9$R9QAXaiLuyqgSSbEdFqzz.C/wm/t4cFbwYg3un1lhp4bAJfolPISpJVcQlXSqoGKTbO3dbdzLQt7Io6J6C85Z/";
      "${config.vars.username}" = {
        shell = pkgs.fish;
        hashedPassword = "$6$ZSnhFmZWAGBUh$eFMNPX2F/.6DKag10p1EM9bLsDwhMcRsb9DGg.qrGDBOK40VpDxNfx7jrD6uGOKb.bT2M0WN4YtJWpDy3GORW0";
        isNormalUser = true;
        extraGroups = [ "wheel" ]
          ++ pkgs.lib.optional config.virtualisation.libvirtd.enable "libvirtd"
          ++ pkgs.lib.optional config.networking.networkmanager.enable "networkmanager"
          ++ pkgs.lib.optional config.programs.light.enable "video";
      };
    };
  };
}
