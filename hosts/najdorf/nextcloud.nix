{
  self,
  config,
  pkgs,
  lib,
  ...
}:

let
  fqdn = "nextcloud.${config.vars.domainName}";
  url = "https://${fqdn}";
  port = 9821;
  collaboraCfg = config.services.collabora-online;
in
{
  age.secrets = {
    nextcloudSecrets.file = "${self}/secrets/nextcloud/secrets.age";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    hostName = fqdn;

    database.createLocally = true;
    config = {
      dbtype = "pgsql";
    };

    maxUploadSize = "16G";
    https = true;

    notify_push.enable = true;
    notify_push.nextcloudUrl = url;

    autoUpdateApps.enable = false;
    autoUpdateApps.startAt = "05:00:00";

    phpOptions = {
      "opcache.interned_strings_buffer" = "32";
    };

    secretFile = config.age.secrets.nextcloudSecrets.path;
    settings = {
      log_type = "file";
      trusted_proxies = [
        "127.0.0.1"
        "::1"
        "2001:861:3884:4fd0::/64"
      ];
      overwriteprotocol = "https";
      default_phone_region = "FR";
      maintenance_window_start = 1;

      mail_smtpmode = "smtp";
      mail_smtphost = config.vars.smtp.host;
      mail_smtpport = config.vars.smtp.port;
      mail_smtpname = config.vars.smtp.user;
      mail_smtpsecure = "ssl";
      mail_from_address = config.vars.email;
      mail_domain = builtins.elemAt (lib.strings.splitString "@" config.vars.email) 1;
    };

    # Leaving the app store enabled gives Nextcloud a writable app dir, which it
    # unpacks app store updates into even for apps served from the read-only
    # nix-apps dir. Two copies of the same app then get loaded in one PHP
    # process, which is a hard fatal for any app whose composer autoloader class
    # name is version-independent (contacts). So every app has to come from Nix.
    appstoreEnable = false;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts;
      inherit forms;
      inherit polls;
      inherit richdocuments;
      inherit music;
      inherit gpoddersync;
      inherit guests;
      inherit previewgenerator;

      cardhook = pkgs.fetchFromGitHub {
        owner = "sweenu";
        repo = "cardhook";
        rev = "main";
        sha256 = "sha256-Ghd2Hm8SI4h7DM5AKV/WQ/muZM3eGZ8UvXswcXeZvWo=";
      };

      duplicatefinder = pkgs.fetchNextcloudApp {
        appName = "duplicatefinder";
        appVersion = "1.9.0";
        url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.9.0/duplicatefinder-v1.9.0.tar.gz";
        hash = "sha256-oiIAZaIJcYM440pZeW6onibM7ELSWaJvWLW1heZv2Bw=";
        license = "agpl3Plus";
      };

      epubviewer = pkgs.fetchNextcloudApp {
        appName = "epubviewer";
        appVersion = "1.9.18";
        url = "https://github.com/devnoname120/epubviewer/releases/download/1.9.18/epubviewer-1.9.18.tar.gz";
        hash = "sha256-MN46C/YLENfjbWELzR3gh+rHZbQjUaw8BHLM2oA95yk=";
        license = "agpl3Plus";
      };

      workflow_pdf_converter = pkgs.fetchNextcloudApp {
        appName = "workflow_pdf_converter";
        appVersion = "6.0.0";
        url = "https://github.com/nextcloud-releases/workflow_pdf_converter/releases/download/v6.0.0/workflow_pdf_converter-v6.0.0.tar.gz";
        hash = "sha256-qniNmi79ERveq9kPrFHty3AZmu1W8FzD/Dwp1ro3t4Q=";
        license = "agpl3Plus";
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    defaultListen = [ ];
    virtualHosts.${fqdn} = {
      forceSSL = false;
      listen = [
        {
          addr = "0.0.0.0";
          port = port;
        }
      ];
      extraConfig = ''
        set_real_ip_from 127.0.0.1;
        set_real_ip_from ::1;
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;
      '';
    };
  };

  services.collabora-online = {
    enable = true;
    port = 9980;
    settings = {
      server_name = "collabora.${config.vars.domainName}";
      ssl = {
        enable = false;
        termination = true;
      };
      net = {
        listen = "loopback";
        post_allow.host = [
          "127.0.0.1"
          "::1"
        ];
      };
      storage.wopi = {
        "@allow" = true;
        host = [ fqdn ];
        alias_groups = {
          "@mode" = "groups";
          group = [
            {
              "@allow" = true;
              host = url;
              alias = "http://localhost:${builtins.toString port}";
            }
          ];
        };
      };
    };
  };

  systemd.services.nextcloud-notify_push.environment.NEXTCLOUD_URL =
    lib.mkForce "http://localhost:${builtins.toString port}";

  systemd.services.nextcloud-setup-collabora =
    let
      inherit (config.services.nextcloud) occ;
      wopi_url = "http://localhost:${toString collaboraCfg.port}";
      public_wopi_url = "https://${collaboraCfg.settings.server_name}";
      wopi_allowlist = "127.0.0.1,::1,2001:861:3884:4fd0:8ceb:7d56:bf25:5a17";
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [
        "nextcloud-setup.service"
        "coolwsd.service"
      ];
      requires = [ "coolwsd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${lib.getExe occ} config:app:set richdocuments wopi_url --value "${wopi_url}"
        ${lib.getExe occ} config:app:set richdocuments public_wopi_url --value "${public_wopi_url}"
        ${lib.getExe occ} config:app:set richdocuments wopi_allowlist --value "${wopi_allowlist}"
      '';
    };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-nextcloud = {
      rule = "Host(`${fqdn}`)";
      service = "nextcloud";
    };
    routers.to-collabora = {
      rule = "Host(`${collaboraCfg.settings.server_name}`)";
      service = "collabora";
    };
    services = {
      "${routers.to-nextcloud.service}".loadBalancer.servers = [
        {
          url = "http://localhost:${builtins.toString port}";
        }
      ];
      "${routers.to-collabora.service}".loadBalancer.servers = [
        {
          url = "http://localhost:${builtins.toString collaboraCfg.port}";
        }
      ];
    };
  };

  services.journal-brief.settings.exclusions = [
    {
      SYSLOG_IDENTIFIER = [ "postgres" ];
      MESSAGE = [
        "/.*duplicate key value violates unique constraint \"oc_filecache_extended_pkey\".*/"
        "/.*Key \\(fileid\\)=\\(\\d+\\) already exists.*/"
        "/.*INSERT INTO \"oc_filecache_extended\".*/"
      ];
    }
  ];

  services.restic.backups.opt.paths = [ config.services.nextcloud.home ];
}
