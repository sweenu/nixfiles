{ pkgs, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/TGros-Dubois/Create-Co/raw/c0d4bafcf046a5ba139af3d6136c9cd3adf911fa/pack.toml";
    packHash = "sha256-8qldwp9EtJyu/fKRTYcGXqiUQXKUjAW+I3w3nu4AXLg=";
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
        view-distance = 18;
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
