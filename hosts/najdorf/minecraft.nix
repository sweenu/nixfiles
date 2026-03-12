{ pkgs, ... }:

let
  cobblemonPort = 25565;
  cobblemonPortStr = builtins.toString cobblemonPort;
  modpack = pkgs.fetchModrinthModpack {
    url = "https://cdn.modrinth.com/data/5FFgwNNP/versions/Lydu1ZNo/Cobblemon%20Modpack%20%5BFabric%5D%201.7.3.mrpack";
    packHash = "sha256-UnE56M+zvard4/TxrEypr1EtFbsG+Cr0b4RUXAIZ5j4=";
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.cobblemon = {
      enable = true;
      inherit modpack;
      managementSystem = {
        tmux.enable = true;
        systemd-socket.enable = false;
      };
      autoStart = true;

      jvmOpts = "-Xms4G -Xmx8G";

      serverProperties = {
        motd = "Cobblemon";
        max-players = 10;
        online-mode = true;
        server-port = cobblemonPort;
        view-distance = 18;
        enforce-secure-profile = true;
      };
    };
  };

  services.tailscale.serve.services.mc-cobblemon.endpoints."tcp:${cobblemonPortStr}" =
    "http://localhost:${cobblemonPortStr}";
}
