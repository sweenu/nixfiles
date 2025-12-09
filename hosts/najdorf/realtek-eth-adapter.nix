{
  self,
  config,
  pkgs,
  ...
}:
let
  r8152 = (
    pkgs.callPackage "${self}/pkgs/realtek-r8152.nix" {
      inherit (config.boot.kernelPackages) kernel kernelModuleMakeFlags;
    }
  );
in
{
  boot = {
    initrd = {
      availableKernelModules = [ "r8152" ];
      kernelModules = [ "r8152" ];
    };
    extraModulePackages = [ r8152 ];
  };

  services.udev.packages = [ r8152 ];
}
