{ config, ... }:

{
  programs.geoland = {
    enable = true;
    interval = "5m";
    settings = {
      loglevel = "info";
      email = {
        host = config.vars.smtpHost;
        port = config.vars.smtpPort;
        username = config.vars.smtpUsername;
        password = "yes";
      };
      sources = {
        xe = {
          type = "feed";
          url = "https://xeiaso.net/blog.json";
          filters = [ "first(3)" ];
        };
        determinate-systems = {
          type = "feed";
          url = "https://determinate.systems/posts?format=rss";
          filters = [ "first(5)" ];
        };
        all = {
          type = "merge";
          sources = [ "xe" "determinate-systems" ];
          filters = [ "digest" ];
        };
        pipes.weekly-digest = {
          source = "all";
          destination = "email";
        };
      };
    };
  };
}
