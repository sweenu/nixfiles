{
  self,
  config,
  pkgs,
  lib,
  ...
}:

let
  fqdn = "nextcloud.${config.vars.domainName}";
  port = 9821;
  collaboraCfg = config.services.collabora-online;
in
{
  age.secrets = {
    nextcloudAdminPass.file = "${self}/secrets/nextcloud/admin_password.age";
    nextcloudSecrets.file = "${self}/secrets/nextcloud/secrets.age";
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = fqdn;

    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = "sweenu";
      adminpassFile = config.age.secrets.nextcloudAdminPass.path;
    };

    maxUploadSize = "16G";
    https = true;

    notify_push.enable = true;
    notify_push.nextcloudUrl = "http://localhost:${builtins.toString port}";

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
      mail_smtpsecure = "tls";
      mail_from_address = config.vars.email;
      mail_domain = builtins.elemAt (lib.strings.splitString "@" config.vars.email) 1;
    };

    appstoreEnable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit contacts;
      inherit forms;
      inherit polls;
      inherit richdocuments;
      inherit music;
      inherit previewgenerator;
      inherit gpoddersync;

      cardhook = pkgs.fetchFromGitHub {
        owner = "sweenu";
        repo = "cardhook";
        rev = "main";
        sha256 = "sha256-eGxmJ2IURQRl71FzDSVg7JXSWNNBBLT+m48NpbCdZRg=";
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
              host = "https://${fqdn}";
              alias = "http://localhost:${builtins.toString port}";
            }
          ];
        };
      };
    };
  };

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

  services.restic.backups.opt.paths = [ config.services.nextcloud.home ];
}
