{
  # Disconnect/re-enumerate loop: disable USB LPM (autosuspend) for the M21.
  boot.kernelParams = [ "usbcore.quirks=2972:0045:k" ];

  # The M21 negotiates a huge buffer (period-num 128 * 256 frames ~= 0.7s),
  # making audio lag behind video. Cap it to a sane period count.
  services.pipewire.wireplumber.extraConfig."10-fiio-m21-latency" = {
    "monitor.alsa.rules" = [
      {
        matches = [ { "node.name" = "~alsa_output.usb-FiiO_FiiO_M21.*"; } ];
        actions = {
          update-props = {
            "api.alsa.period-num" = 2;
          };
        };
      }
    ];
  };
}
