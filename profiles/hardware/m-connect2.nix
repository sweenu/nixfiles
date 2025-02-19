{ ... }:

{
  services.xserver.videoDrivers = [ "displaylink" ];
  systemd.services.dlm.wantedBy = [ "multi-user.target" ];
  environment.variables = {
    WLR_EVDI_RENDER_DEVICE = "/dev/dri/card1";
  };
}
