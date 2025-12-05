{
  self,
  config,
  lib,
  ...
}:

let
  instance = "main";
  autheliaUser = config.services.authelia.instances."${instance}".user;
  dbUser = autheliaUser;
  dbName = dbUser;
  fqdn = "authelia.${config.vars.domainName}";
  autheliaPort = 9091;
  lldapConfig = config.services.lldap.settings;
in
{
  age.secrets = {
    "authelia/jwtSecret" = {
      file = "${self}/secrets/authelia/jwt_secret.age";
      owner = autheliaUser;
    };
    "authelia/sessionSecret" = {
      file = "${self}/secrets/authelia/session_secret.age";
      owner = autheliaUser;
    };
    "authelia/storageEncryptionKey" = {
      file = "${self}/secrets/authelia/storage_encryption_key.age";
      owner = autheliaUser;
    };
    "authelia/ldapPassword" = {
      file = "${self}/secrets/authelia/ldap_password.age";
      owner = autheliaUser;
    };
    "authelia/oidcHmacSecret" = {
      file = "${self}/secrets/authelia/oidc_hmac_secret.age";
      owner = autheliaUser;
    };
    "authelia/oidcJwtPrivateKey" = {
      file = "${self}/secrets/authelia/oidc_jwt_private_key.age";
      owner = autheliaUser;
    };
  };

  users.users."${autheliaUser}".extraGroups = [ "smtp" ];

  systemd.services."authelia-${instance}".after = [ "lldap.service" ];

  services.authelia.instances."${instance}" = {
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
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
        config.age.secrets."authelia/ldapPassword".path;
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
            basic-auth = {
              implementation = "ForwardAuth";
              authn_strategies = [
                {
                  name = "HeaderAuthorization";
                  schemes = [ "Basic" ];
                }
              ];
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
        username = config.vars.smtp.user;
        address = "submissions://${config.vars.smtp.host}:${toString config.vars.smtp.port}";
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
    middlewares =
      let
        forwardAuth = endpoint: {
          address = "http://localhost:${builtins.toString autheliaPort}/api/authz/${endpoint}";
          trustForwardHeader = true;
          authResponseHeaders = [
            "Remote-User"
            "Remote-Groups"
            "Remote-Email"
            "Remote-Name"
          ];
        };
      in
      {
        authelia.forwardAuth = forwardAuth "forward-auth";
        authelia-basic.forwardAuth = forwardAuth "basic-auth";
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
    ensureUsers = [
      {
        name = dbUser;
        ensureDBOwnership = true;
      }
    ];
  };
}
