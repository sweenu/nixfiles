{ self, config, ... }:

let
  lastWeekFilter = "lasthours(${7 * 24})";
  defaultFilters = [ lastWeekFilter "link" ];
in
{
  age.secrets.smtpPassword.file = "${self}/secrets/smtp_password.age";

  programs.goeland = {
    enable = true;
    interval = "Mon, 0:00:00";
    settings = {
      loglevel = "info";
      # loglevel = "error";
      email = {
        host = config.vars.smtpHost;
        port = config.vars.smtpPort;
        username = config.vars.smtpUsername;
        password_file = config.age.secrets.smtpPassword.path;
        include-header = true;
        include-footer = true;
        include-title = true;
      };
      pipes.weekly-digest = {
        source = "all";
        destination = "email";
        email_to = [ config.vars.email ];
        email_from = "goeland <${config.vars.email}>";
        email_title = "Weekly digest";
      };
      sources = {
        xe = {
          type = "feed";
          url = "https://xeiaso.net/blog.json";
          filters = defaultFilters;
        };
        determinate-systems = {
          type = "feed";
          url = "https://determinate.systems/posts?format=rss";
          filters = defaultFilters;
        };
        all = {
          type = "merge";
          sources = [ "xe" "determinate-systems" ];
          # filters = [ "digest" ];
        };
      };
    };
  };
}
