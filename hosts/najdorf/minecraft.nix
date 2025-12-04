{ pkgs, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/sweenu/Create-Co/raw/9523ba1fae88ecda89a0581ac08bae427e6295e6/pack.toml";
    packHash = "sha256-vv9Ec9iyaok4mBXMIL3jlBmW/lnKBX2tbv31zFTM3Nc=";
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
        tmux.enable = false;
        systemd-socket.enable = true;
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
        config = "${modpack}/config";
      };
    };
  };
}
