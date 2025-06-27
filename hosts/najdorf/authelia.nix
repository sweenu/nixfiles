{ self, config, lib, ... }:

let
  autheliaPort = 9091;
  fqdn = "authelia.${config.vars.domainName}";
  lldapConfig = config.services.lldap.settings;
  dbUser = config.services.authelia.instances.main.user;
  dbName = dbUser;
in
{
  age.secrets = {
    "authelia/jwtSecret" = {
      file = "${self}/secrets/authelia/jwt_secret.age";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia/sessionSecret" = {
      file = "${self}/secrets/authelia/session_secret.age";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia/storageEncryptionKey" = {
      file = "${self}/secrets/authelia/storage_encryption_key.age";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia/ldapPassword" = {
      file = "${self}/secrets/authelia/ldap_password.age";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia/oidcHmacSecret" = {
      file = "${self}/secrets/authelia/oidc_hmac_secret.age";
      owner = config.services.authelia.instances.main.user;
    };
    "authelia/oidcJwtPrivateKey" = {
      file = "${self}/secrets/authelia/oidc_jwt_private_key.age";
      owner = config.services.authelia.instances.main.user;
    };
  };

  users.users."${config.services.authelia.instances.main.user}".extraGroups = [ "smtp" ];

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      storageEncryptionKeyFile = config.age.secrets."authelia/storageEncryptionKey".path;
      jwtSecretFile = config.age.secrets."authelia/jwtSecret".path;
      sessionSecretFile = config.age.secrets."authelia/sessionSecret".path;
      oidcHmacSecretFile = config.age.secrets."authelia/oidcHmacSecret".path;
      oidcIssuerPrivateKeyFile = config.age.secrets."authelia/oidcJwtPrivateKey".path;
    };
    environmentVariables = {
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.age.secrets.smtpPassword.path;
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = config.age.secrets."authelia/ldapPassword".path;
    };
    settings = {
      theme = "auto";
      server = {
        address = "tcp://:${builtins.toString autheliaPort}/";
        buffers = {
          read = 16384;
        };
        endpoints = {
          authz = {
            forward-auth = {
              implementation = "ForwardAuth";
            };
          };
        };
      };
      log.level = "warn";
      storage.postgres = {
        address = "unix:///run/postgresql";
        database = dbName;
        username = dbUser;
      };
      totp = {
        issuer = "${fqdn}";
        period = 30;
        skew = 1;
      };
      authentication_backend = {
        password_reset.disable = false;
        refresh_interval = "1m";
        ldap = {
          implementation = "lldap";
          address = "ldap://${lldapConfig.ldap_host}:${builtins.toString lldapConfig.ldap_port}";
          base_dn = lldapConfig.ldap_base_dn;
          user = "uid=authelia,ou=people,${lldapConfig.ldap_base_dn}";
          users_filter = "(&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))";
          groups_filter = "(&(member={dn})(objectClass=groupOfNames))";
        };
      };
      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "*.${config.vars.domainName}";
            subject = [ "user:sweenu" ];
            policy = "two_factor";
          }
          {
            domain_regex = "^(?P<Group>\\w+)\\.${lib.strings.escapeRegex config.vars.domainName}$";
            policy = "one_factor";
          }
          {
            domain = "n8n.${config.vars.domainName}";
            resources = [ "^/form/.*" ];
            methods = [ "GET" "POST" ];
            policy = "bypass";
          }
        ];
      };
      session = {
        expiration = "1h";
        inactivity = "5m";
        remember_me = "3M";
        cookies = [
          {
            domain = config.vars.domainName;
            authelia_url = "https://${fqdn}";
            default_redirection_url = "https://${fqdn}/";
          }
        ];
      };
      regulation = {
        max_retries = 3;
        find_time = "2m";
        ban_time = "10m";
      };
      notifier.smtp = {
        username = config.vars.smtpUsername;
        address = "submissions://${config.vars.smtpHost}:${toString config.vars.smtpPort}";
        sender = "Authelia <${config.vars.email}>";
        identifier = config.vars.domainName;
      };
      password_policy.standard = {
        enabled = true;
        min_length = 8;
        max_length = 0;
      };
      ntp.address = "${builtins.head config.networking.timeServers}:123";
    };
  };

  services.traefik.dynamicConfigOptions.http = rec {
    middlewares = {
      authelia.forwardAuth = {
        address = "http://localhost:${builtins.toString autheliaPort}/api/authz/forward-auth";
        trustForwardHeader = true;
        authResponseHeaders = [
          "Remote-User"
          "Remote-Groups"
          "Remote-Email"
          "Remote-Name"
        ];
      };

      authelia-headers = {
        headers = {
          browserXssFilter = true;
          customFrameOptionsValue = "SAMEORIGIN";
          customResponseHeaders = {
            "Cache-Control" = "no-store";
            "Pragma" = "no-cache";
          };
        };
      };
    };

    routers.to-authelia = {
      rule = "Host(`${fqdn}`)";
      service = "authelia";
      middlewares = [ "authelia-headers" ];
    };

    services."${routers.to-authelia.service}".loadBalancer.servers = [
      {
        url = "http://localhost:${builtins.toString autheliaPort}";
      }
    ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ dbName ];
    ensureUsers = [{
      name = dbUser;
      ensureDBOwnership = true;
    }];
  };
}
