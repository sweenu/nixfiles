{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.opodsync;

  phpPackage = pkgs.php83.withExtensions (
    { all, ... }:
    with all;
    [
      sqlite3
      pdo
      pdo_sqlite
      curl
      mbstring
      openssl
      session
      ctype
      fileinfo
      filter
      iconv
      simplexml
      dom
    ]
  );

  poolName = "opodsync";
  user = "opodsync";
  group = "opodsync";

in
{
  options.services.opodsync = {
    enable = mkEnableOption "oPodSync podcast synchronization server";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for the oPodSync web interface";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/opodsync";
      description = "Directory to store oPodSync data";
    };

    schedule = mkOption {
      type = types.str;
      default = "hourly";
      description = "Schedule for updating podcast feed metadata (systemd calendar format)";
      example = "Mon, 00:00:00";
    };

    config = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "oPodSync configuration options";
      example = literalExpression ''
        {
          BASE_URL = "https://podcasts.example.com";
          DISABLE_USER_METADATA_UPDATE = true;
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.${user} = {
      isSystemUser = true;
      group = group;
    };

    users.groups.${group} = { };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0755 ${user} ${group} - -"
      "d '${cfg.dataDir}/app' 0755 ${user} ${group} - -"
      "d '${cfg.dataDir}/data' 0755 ${user} ${group} - -"
    ];

    environment.etc."opodsync/config.local.php" = mkIf (cfg.config != { }) {
      text = ''
        <?php
        ${concatStringsSep "\n" (
          mapAttrsToList (
            name: value:
            if builtins.isString value then
              "define('${name}', '${value}');"
            else if builtins.isBool value then
              "define('${name}', ${if value then "TRUE" else "FALSE"});"
            else if builtins.isInt value then
              "define('${name}', ${toString value});"
            else
              "define('${name}', '${toString value}');"
          ) cfg.config
        )}
      '';
      mode = "0644";
      user = user;
      group = group;
    };

    # Setup oPodSync application and data directories
    systemd.services.opodsync-setup = {
      description = "Setup oPodSync application and data directories";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];
      before = [
        "nginx.service"
        "phpfpm-opodsync.service"
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = user;
        Group = group;
      };

      script = ''
                # Create application directory
                mkdir -p ${cfg.dataDir}/app

                # Copy opodsync files to writable location
                if [ ! -f ${cfg.dataDir}/app/index.php ] || [ ${pkgs.opodsync}/share/opodsync/index.php -nt ${cfg.dataDir}/app/index.php ]; then
                  echo "Copying oPodSync files to ${cfg.dataDir}/app"
                  cp -r ${pkgs.opodsync}/share/opodsync/* ${cfg.dataDir}/app/
                  chown -R ${user}:${group} ${cfg.dataDir}/app
                fi

                # Create debug script to check PHP variables
                cat > ${cfg.dataDir}/app/debug.php <<'EOFPHP'
        <?php
        header('Content-Type: text/plain');
        echo "=== PHP Debug Info ===\n\n";
        echo "REQUEST_URI: " . ($_SERVER['REQUEST_URI'] ?? 'NOT SET') . "\n";
        echo "SCRIPT_NAME: " . ($_SERVER['SCRIPT_NAME'] ?? 'NOT SET') . "\n";
        echo "SCRIPT_FILENAME: " . ($_SERVER['SCRIPT_FILENAME'] ?? 'NOT SET') . "\n";
        echo "DOCUMENT_URI: " . ($_SERVER['DOCUMENT_URI'] ?? 'NOT SET') . "\n";
        echo "QUERY_STRING: " . ($_SERVER['QUERY_STRING'] ?? 'NOT SET') . "\n";
        echo "REQUEST_METHOD: " . ($_SERVER['REQUEST_METHOD'] ?? 'NOT SET') . "\n";
        echo "HTTP_AUTHORIZATION: " . (isset($_SERVER['HTTP_AUTHORIZATION']) ? 'SET (hidden)' : 'NOT SET') . "\n";
        echo "\n=== All \$_SERVER vars ===\n";
        print_r($_SERVER);
        EOFPHP
                chown ${user}:${group} ${cfg.dataDir}/app/debug.php

                # Ensure data directory exists and is properly linked
                mkdir -p ${cfg.dataDir}/data
                rm -f ${cfg.dataDir}/app/data
                ln -sf ${cfg.dataDir}/data ${cfg.dataDir}/app/data

                # Link config file if it exists
                ${optionalString (cfg.config != { }) ''
                  ln -sf /etc/opodsync/config.local.php ${cfg.dataDir}/data/config.local.php
                ''}

                # Set proper permissions
                chown -R ${user}:${group} ${cfg.dataDir}
      '';
    };

    services.phpfpm.pools.${poolName} = {
      user = user;
      group = group;
      phpPackage = phpPackage;

      settings = {
        "listen.owner" = "nginx";
        "listen.group" = "nginx";
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
        "catch_workers_output" = "yes";
        "decorate_workers_output" = "no";
      };

      phpEnv = {
        OPODSYNC_DATA_DIR = cfg.dataDir;
      }
      // (mapAttrs (
        name: value: if builtins.isBool value then (if value then "1" else "0") else toString value
      ) cfg.config);

      phpOptions = ''
        log_errors = on
      '';
    };

    services.nginx = {
      enable = true;
      user = "nginx";
      group = "nginx";
      virtualHosts."opodsync-internal" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.port;
          }
        ];

        root = "${cfg.dataDir}/app";

        locations = {
          # Protect sensitive directories
          "~ ^/(lib|data|templates|sql)/" = {
            return = "404";
          };

          # Handle PHP files
          "~ \\.php$" = {
            extraConfig = ''
              fastcgi_pass unix:${config.services.phpfpm.pools.${poolName}.socket};
              include ${pkgs.nginx}/conf/fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param HTTP_AUTHORIZATION $http_authorization;
            '';
          };

          # Default handler - everything else goes to index.php (FallbackResource)
          "/" = {
            index = "index.php index.html";
            tryFiles = "$uri $uri/ /index.php$is_args$args";
          };
        };

        extraConfig = ''
          client_max_body_size 100M;
        '';
      };
    };

    # Systemd service for periodic feed updates
    systemd.services.opodsync-update-feeds = {
      description = "Update oPodSync feeds metadata";

      serviceConfig = {
        Type = "oneshot";
        User = user;
        Group = group;
        WorkingDirectory = "${cfg.dataDir}/app";
      };

      environment = {
        OPODSYNC_DATA_DIR = cfg.dataDir;
      }
      // (mapAttrs (name: value: toString value) cfg.config);

      script = ''
        ${phpPackage}/bin/php index.php
      '';
    };

    systemd.timers.opodsync-update-feeds = {
      description = "Update oPodSync feeds metadata periodically";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
        AccuracySec = "1m";
      };
    };

  };
}
