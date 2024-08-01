{ self, config, ... }:

{
  age.secrets.smtpPassword = {
    file = "${self}/secrets/smtp_password.age";
    owner = config.vars.username;
  };

  home-manager.users."${config.vars.username}" = {
    accounts.email.accounts.fastmail = {
      primary = true;
      flavor = "fastmail.com";
      address = "contact@sweenu.xyz";
      realName = "Bruno Inec";
      passwordCommand = "cat ${config.age.secrets.smtpPassword.path}";
    };
  };
}
