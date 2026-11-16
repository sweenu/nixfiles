{
  self,
  config,
  pkgs,
  ...
}:

let
  user = "mail-backup";
  stateDir = "/var/lib/${user}";

  # Pull-only: the server is never modified. Expunge None keeps mail deleted
  # on the server; with it, Remove Near never deletes a folder (mbsync only
  # removes empty ones) but stops erroring when one vanishes upstream.
  mbsyncrc = pkgs.writeText "mbsyncrc" ''
    IMAPAccount fastmail
    Host imap.fastmail.com
    TLSType IMAPS
    CertificateFile /etc/ssl/certs/ca-certificates.crt
    User ${config.vars.email}
    PassCmd "${pkgs.coreutils}/bin/cat ${config.age.secrets.fastmailAppPassword.path}"

    IMAPStore fastmail-remote
    Account fastmail

    MaildirStore fastmail-local
    Path ${stateDir}/
    Inbox ${stateDir}/Inbox
    SubFolders Verbatim

    Channel fastmail
    Far :fastmail-remote:
    Near :fastmail-local:
    Patterns *
    Sync Pull
    Create Near
    Remove Near
    Expunge None
    SyncState *
  '';
in
{
  age.secrets.fastmailAppPassword = {
    file = "${self}/secrets/fastmail/app_password.age";
    owner = user;
  };

  users.users.${user} = {
    isSystemUser = true;
    group = user;
  };
  users.groups.${user} = { };

  systemd.services.mail-backup = {
    description = "Mirror the Fastmail mailbox for restic";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # Lands just before the hourly restic run.
    startAt = "*-*-* *:50:00";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      Group = user;
      StateDirectory = user;
      StateDirectoryMode = "0700";
      ExecStart = "${pkgs.isync}/bin/mbsync --config ${mbsyncrc} --all";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  services.restic.backups.opt.paths = [ stateDir ];
}
