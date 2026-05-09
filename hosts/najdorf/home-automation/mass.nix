{ lib, ... }:

let
  massWebPort = 8095;
in
{
  networking.firewall.extraCommands = ''
    # Music Assistant
    ${lib.openTCPPortForLAN massWebPort} # web interface
    ${lib.openTCPPortForLAN 8097} # web socket
    # Squeezlite
    ${lib.openTCPPortForLAN 3483}
    ${lib.openUDPPortForLAN 3483}
    ${lib.openTCPPortForLAN 9090}
    # Spotify Connect & more (ephemeral ports)
    ${lib.openTCPPortRangeForLAN 32768 65535}
    ${lib.openUDPPortRangeForLAN 32768 65535}
  '';

  services.music-assistant = {
    enable = true;
    providers = [
      "hass"
      "hass_players"
      "spotify"
      "spotify_connect"
      "squeezelite"
      "sendspin"
    ];
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services = {
  #   mass.https."443" = "http://localhost:${builtins.toString massWebPort}";
  # };
}
