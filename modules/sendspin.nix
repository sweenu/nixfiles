{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sendspin;
in
{
  options.services.sendspin = {
    enable = lib.mkEnableOption "Sendspin synchronized audio player";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sendspin-cli;
      defaultText = lib.literalExpression "pkgs.sendspin-cli";
      description = "The sendspin-cli package to use.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "sendspin";
      description = "User account under which sendspin runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "sendspin";
      description = "Group under which sendspin runs.";
    };

    clientId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Unique identifier for this client. Defaults to sendspin-<hostname>.";
    };

    clientName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Friendly name displayed on the server. Defaults to hostname.";
    };

    serverUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "ws://192.168.1.100:8080/sendspin";
      description = "URL of the Sendspin server to connect to. If null, uses mDNS discovery.";
    };

    audioDevice = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.int lib.types.str);
      default = null;
      example = 2;
      description = "Audio output device index or name prefix. If null, uses system default.";
    };

    staticDelayMs = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = -100;
      description = "Static playback delay in milliseconds to compensate for audio hardware latency.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "DEBUG"
        "INFO"
        "WARNING"
        "ERROR"
        "CRITICAL"
      ];
      default = "INFO";
      description = "Logging level for sendspin.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--some-option" ];
      description = "Additional command-line arguments to pass to sendspin.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      extraGroups = [ "audio" ];
      description = "Sendspin service user";
    };

    users.groups.${cfg.group} = { };

    systemd.services.sendspin = {
      description = "Sendspin Synchronized Audio Player";
      after = [
        "network-online.target"
        "sound.target"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        PrivateMounts = true;

        # Need access to audio devices
        DeviceAllow = [ "/dev/snd" ];
        DevicePolicy = "closed";
      };

      script =
        let
          args = [
            "--headless"
            "--log-level ${cfg.logLevel}"
          ]
          ++ lib.optional (cfg.clientId != null) "--id ${cfg.clientId}"
          ++ lib.optional (cfg.clientName != null) "--name '${cfg.clientName}'"
          ++ lib.optional (cfg.serverUrl != null) "--url ${cfg.serverUrl}"
          ++ lib.optional (cfg.audioDevice != null) "--audio-device ${toString cfg.audioDevice}"
          ++ lib.optional (cfg.staticDelayMs != null) "--static-delay-ms ${toString cfg.staticDelayMs}"
          ++ cfg.extraArgs;
        in
        ''
          exec ${cfg.package}/bin/sendspin ${lib.concatStringsSep " " args}
        '';
    };
  };
}
