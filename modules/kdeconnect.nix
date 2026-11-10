{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.kdeconnect;

  portRange = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  # LanLinkProvider::UDP_PORT, sent to QHostAddress::Broadcast.
  discoveryRule = "OUTPUT -p udp -d 255.255.255.255 --dport 1716 -j DROP";
in
{
  # The upstream module opens 1714-1764 on every interface with no way to opt
  # out, so replace it rather than fight its firewall settings.
  disabledModules = [ "programs/kdeconnect.nix" ];

  options.programs.kdeconnect = {
    enable = lib.mkEnableOption "KDE Connect";

    package = lib.mkPackageOption pkgs [ "kdePackages" "kdeconnect-kde" ] {
      nullable = true;
      example = "gnomeExtensions.gsconnect";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to open TCP and UDP ports 1714-1764 on every interface.

        Leave this off when the peer is only ever reached over an interface
        already listed in {option}`networking.firewall.trustedInterfaces`, such
        as a tailnet. The ports are redundant there, and opening them globally
        exposes the daemon on untrusted networks.
      '';
    };

    announceOnBroadcast = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to let kdeconnectd announce itself to the IPv4 broadcast
        address.

        Every discovery round it sends an identity packet carrying its device ID
        and name to 255.255.255.255, from each interface that is up. On
        untrusted networks that is an unsolicited beacon, and a stable one, so
        it survives MAC randomisation.

        kdeconnectd has no setting for this. Its
        `KDECONNECT_DISABLE_UDP_BROADCAST` variable is an early return in
        `broadcastUdpIdentityPacket()`, which also suppresses the unicast to
        every {option}`programs.kdeconnect.customDevices` entry, because both
        share that one code path. Filtering on the destination address instead
        drops only the broadcast and leaves the custom-device path working.

        Turning this off disables broadcast discovery, so only do it when every
        peer is listed in customDevices.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.announceOnBroadcast || !config.networking.nftables.enable;
        message = ''
          programs.kdeconnect.announceOnBroadcast = false uses
          networking.firewall.extraCommands, which the nftables backend ignores.
          Port it to a nftables output rule before enabling nftables.
        '';
      }
    ];

    environment.systemPackages = lib.optionals (cfg.package != null) [ cfg.package ];

    # digitizer plugin requires uinput
    hardware.uinput.enable = lib.mkDefault true;

    networking.firewall = lib.mkMerge [
      (lib.mkIf cfg.openFirewall {
        allowedTCPPortRanges = portRange;
        allowedUDPPortRanges = portRange;
      })
      (lib.mkIf (!cfg.announceOnBroadcast) {
        extraCommands = "iptables -A ${discoveryRule}";
        extraStopCommands = "iptables -D ${discoveryRule} || true";
      })
    ];
  };
}
