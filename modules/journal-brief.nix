{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.journal-brief;
  format = pkgs.formats.yaml { };
  stateDir = "/var/lib/journal-brief";

  smtpEnabled = cfg.smtp != null;

  smtpSettings = lib.optionalAttrs smtpEnabled {
    email = {
      command = "/run/wrappers/bin/sendmail -a journal-brief -i -t";
      from = cfg.smtp.from;
      to = cfg.smtp.to;
    };
  };

  finalSettings = lib.recursiveUpdate (lib.recursiveUpdate {
    cursor-file = "${stateDir}/cursor";
  } cfg.settings) smtpSettings;

  configFile = format.generate "journal-brief.conf" finalSettings;
in
{
  options.services.journal-brief = {
    enable = lib.mkEnableOption "journal-brief: send interesting journal entries since last run";

    package = lib.mkPackageOption pkgs "journal-brief" { };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      example = "Mon *-*-* 09:00:00";
      description = "systemd OnCalendar expression controlling when journal-brief runs.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "-p"
        "err"
      ];
      description = "Extra command-line arguments passed to journal-brief.";
    };

    settings = lib.mkOption {
      type = format.type;
      default = { };
      example = lib.literalExpression ''
        {
          priority = "err";
          exclusions = [
            { MESSAGE_ID = [ "c7a787079b354eaaa9e77b371893cd27" ]; }
          ];
        }
      '';
      description = ''
        Contents of the journal-brief YAML configuration file.
        See <https://github.com/twaugh/journal-brief> for the schema.

        Note: this file is rendered to the world-readable Nix store, so do
        not embed secrets (e.g. SMTP passwords) directly here. Use the
        `smtp` option instead for authenticated email delivery.
      '';
    };

    smtp = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              description = "SMTP server hostname.";
            };
            port = lib.mkOption {
              type = lib.types.port;
              default = 587;
              description = "SMTP server port.";
            };
            user = lib.mkOption {
              type = lib.types.str;
              description = "SMTP authentication username.";
            };
            passwordFile = lib.mkOption {
              type = lib.types.path;
              example = lib.literalExpression "config.age.secrets.smtpPassword.path";
              description = ''
                Path to a file containing the SMTP password. msmtp reads it
                at runtime via `passwordeval`, so the password never lands
                in the Nix store.
              '';
            };
            passwordFileGroup = lib.mkOption {
              type = lib.types.str;
              default = "smtp";
              description = ''
                Group that owns `passwordFile`. Added to the journal-brief
                service's supplementary groups so the DynamicUser can read
                the secret.
              '';
            };
            tls = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Use TLS for the SMTP connection.";
            };
            tlsStarttls = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = ''
                Negotiate TLS via STARTTLS. Set to false for implicit TLS
                (smtps, typically port 465).
              '';
            };
            from = lib.mkOption {
              type = lib.types.str;
              description = "RFC-5322 sender address.";
            };
            to = lib.mkOption {
              type = lib.types.either lib.types.str (lib.types.listOf lib.types.str);
              description = "RFC-5322 recipient address (or list).";
            };
          };
        }
      );
      default = null;
      description = ''
        When set, journal-brief delivers email via system sendmail
        (`/run/wrappers/bin/sendmail`). The module enables
        `programs.msmtp` and registers a `journal-brief` account using
        these settings; the SMTP password is read from `passwordFile` at
        runtime via msmtp's `passwordeval`.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = !smtpEnabled || !((cfg.settings.email or { }) ? smtp);
          message = ''
            services.journal-brief.smtp and services.journal-brief.settings.email.smtp
            cannot be set at the same time.
          '';
        }
      ];

      systemd.services.journal-brief = {
        description = "journal-brief: report new systemd journal entries";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          SupplementaryGroups =
            [ "systemd-journal" ]
            ++ lib.optional smtpEnabled cfg.smtp.passwordFileGroup;
          StateDirectory = "journal-brief";
          StateDirectoryMode = "0750";
          ExecStart = "${lib.getExe cfg.package} --conf ${configFile} ${lib.escapeShellArgs cfg.extraArgs}";

          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          NoNewPrivileges = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          LockPersonality = true;
        };
      };

      systemd.timers.journal-brief = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.schedule;
          Persistent = true;
        };
      };
    }

    (lib.mkIf smtpEnabled {
      programs.msmtp = {
        enable = lib.mkDefault true;
        accounts.journal-brief = {
          auth = true;
          tls = cfg.smtp.tls;
          tls_starttls = cfg.smtp.tlsStarttls;
          host = cfg.smtp.host;
          port = cfg.smtp.port;
          user = cfg.smtp.user;
          from = cfg.smtp.from;
          passwordeval = "cat ${cfg.smtp.passwordFile}";
        };
      };
    })
  ]);
}
