{ self, config, ... }:

{
  age.secrets._3proxyUsersFile = {
    file = "${self}/secrets/3proxy_users.age";
    mode = "644";
  };

  services._3proxy = {
    enable = true;
    usersFile = config.age.secrets._3proxyUsersFile.path;
    services = [
      {
        type = "proxy";
        bindPort = 3128;
        auth = [ "strong" ];
        acl = [
          {
            rule = "allow";
            users = [ "sweenu" ];
          }
        ];
      }
    ];
  };
}
