{ config, lib, ... }:

let
  cfg = config.services.jellyfin;
  mediaDir = "/srv/media";
in
{
  # Radeon 760M (VCN 4) VA-API driver comes with Mesa
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
    transcoding = {
      enableHardwareEncoding = true;
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        vp9 = true;
        av1 = true;
      };
      hardwareEncodingCodecs = {
        hevc = true;
        av1 = true;
      };
    };
  };

  # Outside dataDir (mode 700) so I can drop files in; setgid keeps new files in the jellyfin group.
  systemd.tmpfiles.settings.jellyfinMedia =
    lib.genAttrs
      [
        "${mediaDir}/movies"
        "${mediaDir}/shows"
      ]
      (_: {
        d = {
          inherit (cfg) user group;
          mode = "2775";
        };
      });
  users.users.${config.vars.username}.extraGroups = [ cfg.group ];

  services.restic.backups.opt = {
    paths = [ cfg.dataDir ];
    exclude = [ cfg.logDir ];
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.jellyfin.https."443" = "http://localhost:8096";
}
