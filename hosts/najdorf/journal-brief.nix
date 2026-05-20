{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.journal-brief ];

  services.journal-brief = {
    enable = true;
    schedule = "*:0/5";
    settings = {
      priority = "warning";
      email.subject = "Journal brief";
      exclusions = [
        {
          SYSLOG_IDENTIFIER = [ "dbus-broker-launch" ];
          MESSAGE = [ "/Ignoring duplicate name .*/" ];
        }
      ];
    };
    smtp = {
      host = config.vars.smtp.host;
      port = config.vars.smtp.port;
      user = config.vars.smtp.user;
      passwordFile = config.age.secrets.smtpPassword.path;
      tlsStarttls = false;
      from = "Journal Brief<journal-brief@${config.vars.domainName}>";
      to = config.vars.email;
    };
  };
}
