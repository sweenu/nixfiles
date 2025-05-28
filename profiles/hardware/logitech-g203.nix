{ pkgs, ... }:

let
  vendorId = "046d";
  productId = "c092";
  g203-white = pkgs.writeShellScriptBin "g203-white" ''
    ${pkgs.openrgb}/bin/openrgb --noautoconnect --device "Logitech G203 Lightsync" --color FFFFFF
  '';
in
{
  systemd.services.g203-white = {
    description = "g203-white";
    serviceConfig = {
      ExecStart = "${g203-white}/bin/g203-white";
      Type = "oneshot";
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="${vendorId}", ATTRS{idProduct}=="${productId}", TAG+="systemd", ENV{SYSTEMD_WANTS}="g203-white.service"
  '';
}
