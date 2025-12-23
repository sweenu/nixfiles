{ config, ... }:

let
  feeds = {
    xe = "https://xeiaso.net/blog.json";
    determinate-systems = "https://determinate.systems/posts?format=rss";
    emersion = "https://emersion.fr/blog/atom.xml";
    drew-devault = "https://drewdevault.com/blog/index.xml";
    tailscale = "https://tailscale.com/blog/index.xml";
    poettering = "https://0pointer.net/blog/index.atom";
    notion = "https://rss.app/feeds/NsIZtd0vgm0BsqKL.xml";
    starlwart = "https://stalwartlabs.medium.com/feed";
    alternativeto = "https://feed.alternativeto.net/news/all/";
    home-assistant = "https://www.home-assistant.io/atom.xml";
    zed = "https://zed.dev/blog.rss";
    matter-alpha = "https://www.matteralpha.com/feed";
  };
in
{
  users.users.goeland.extraGroups = [ "smtp" ];

  services.goeland = {
    enable = true;
    schedule = "Mon, 00:00:00";
    settings = {
      loglevel = "info";
      email = {
        host = config.vars.smtp.host;
        port = config.vars.smtp.port;
        username = config.vars.smtp.user;
        password_file = config.age.secrets.smtpPassword.path;
        include-header = true;
        include-footer = true;
        include-title = true;
        include-content = false;
        include-toc = true;
        encryption = "ssl";
      };
      pipes.weekly-digest = {
        source = "all";
        destination = "email";
        email_to = [ config.vars.email ];
        email_from = "goeland <${config.vars.email}>";
        email_title = "Weekly digest";
      };
      sources =
        let
          lastWeekFilter = "lasthours(${toString (7 * 24)})";
          defaultFilters = [
            lastWeekFilter
            "includelink"
            "toc(title)"
            "first"
          ];
          makeSource = name: url: {
            type = "feed";
            filters = defaultFilters;
            url = url;
          };
        in
        (builtins.mapAttrs makeSource feeds)
        // {
          all = {
            type = "merge";
            filters = [ "digest" ];
            sources = builtins.attrNames feeds;
          };
        };
    };
  };
}
