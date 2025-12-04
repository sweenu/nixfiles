{ pkgs, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/sweenu/Create-Co/raw/1c01cb29911aeaa1713c6881f00e957a91d4b2c4/pack.toml";
    packHash = "sha256-C6rpzs+IdbJ5S9QgZvBjyHnJHw3HoMXH2HbmENsWEwI=";
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.create-co = {
      enable = true;
      managementSystem = {
        tmux.enable = true;
        systemd-socket.enable = false;
      };
      autoStart = true;

      package = pkgs.neoforgeServers.neoforge-1_21_1-21_1_216;

      jvmOpts = "-Xms4G -Xmx8G";

      serverProperties = {
        motd = "Create & Co";
        max-players = 10;
        online-mode = true;
        server-port = 25565;
      };

      symlinks = {
        mods = "${modpack}/mods";
      };
      files = {
        config = "${modpack}/config";
      };
    };
  };
}
