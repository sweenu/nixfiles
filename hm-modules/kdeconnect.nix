{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.kdeconnect;
  unit = "app-org.kde.kdeconnect.daemon@autostart.service";
in
{
  options.programs.kdeconnect.customDevices = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "100.117.165.6" ];
    description = ''
      Addresses kdeconnectd sends an identity packet to directly, for peers UDP
      broadcast cannot reach: a guest network that drops client-to-client
      broadcast, or a peer only reachable over a tailnet.

      Entries must be literal IP addresses. kdeconnectd parses each one with
      `QHostAddress`, which does not resolve names, and logs
      `Invalid custom device address` for anything else — so a Tailscale
      MagicDNS name does not work here.
    '';
  };

  config = lib.mkIf (cfg.customDevices != [ ]) {
    # kdeconnectd stores this in a QSettings file it shares with its own state
    # (device name, key algorithm), so write the single key instead of managing
    # the whole file.
    home.activation.kdeconnectCustomDevices = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6"} \
        --file kdeconnect/config --group General --key customDevices \
        ${lib.escapeShellArg (lib.concatStringsSep "," cfg.customDevices)}

      # A running daemon would sync its in-memory copy back over the write.
      run --quiet systemctl --user try-restart ${unit} || true
    '';
  };
}
