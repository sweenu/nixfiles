{
  self,
  config,
  lib,
  ...
}:

let
  fqdn = "lldap.${config.vars.domainName}";
  domainParts = lib.strings.splitString "\\." config.vars.domainName;
  dcParts = map (part: "dc=${part}") domainParts;
  baseDN = builtins.concatStringsSep "," dcParts;
  jwtSecretCredName = "jwt_secret";
  ldapUserPassCredName = "ldap_user_pass";
  smtpPasswordCredName = "smtp_password";
  serverKeyCredName = "server_key";
in
{
  age.secrets = {
    "lldap/jwtSecret".file = "${self}/secrets/lldap/jwt_secret.age";
    "lldap/ldapUserPass".file = "${self}/secrets/lldap/ldap_user_pass.age";
    "lldap/serverKey".file = "${self}/secrets/lldap/server_key.age";
  };

  services.lldap = {
    enable = true;
    createLocalDatabase = true;
    environment = {
      LLDAP_JWT_SECRET_FILE = "%d/${jwtSecretCredName}";
      LLDAP_LDAP_USER_PASS_FILE = "%d/${ldapUserPassCredName}";
      LLDAP_SMTP_OPTIONS__PASSWORD_FILE = "%d/${smtpPasswordCredName}";
      LLDAP_KEY_FILE = "%d/${serverKeyCredName}";
    };
    silenceForceUserPassResetWarning = true;
    settings = {
      http_host = "127.0.0.1";
      http_url = "https://${fqdn}";
      ldap_host = "127.0.0.1";
      ldap_base_dn = baseDN;
      ldap_user_dn = "admin";
      ldap_user_email = config.vars.email;
      smtp_options = {
        server = config.vars.smtp.host;
        port = config.vars.smtp.port;
        user = config.vars.smtp.user;
        from = "LLDAP Admin <${config.vars.email}>";
        reply_to = "Do not reply <noreply@${config.vars.domainName}>";
      };
    };
  };

  systemd.services.lldap.serviceConfig = {
    SupplementaryGroups = "smtp";
    LoadCredential = [
      "${jwtSecretCredName}:${config.age.secrets."lldap/jwtSecret".path}"
      "${ldapUserPassCredName}:${config.age.secrets."lldap/ldapUserPass".path}"
      "${serverKeyCredName}:${config.age.secrets."lldap/serverKey".path}"
      "${smtpPasswordCredName}:${config.age.secrets.smtpPassword.path}"
    ];
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-lldap = {
      rule = "Host(`${fqdn}`)";
      service = "lldap";
    };
    services."${routers.to-lldap.service}".loadBalancer.servers = [
      {
        url = "http://${config.services.lldap.settings.http_host}:${builtins.toString config.services.lldap.settings.http_port}";
      }
    ];
  };
}
