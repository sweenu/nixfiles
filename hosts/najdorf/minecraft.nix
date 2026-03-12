{ pkgs, ... }:

let
  creabblemonPort = 25565;
  creabblemonPortStr = builtins.toString creabblemonPort;
  modpack = pkgs.fetchModrinthModpack {
    url = "https://github.com/sweenu/mc-modpacks/releases/download/v26.03.301019/creabblemon-fabric.mrpack";
    packHash = "sha256-TIxrw35tBinvVTSh0Fxhi0oGtGQ5txj1/qLme4gpw60=";
  };
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.creabblemon = {
      enable = true;
      managementSystem = {
        tmux.enable = false;
        systemd-socket.enable = true;
      };
      autoStart = true;
      package = pkgs.fabricServers.fabric-1_20_1.override {
        loaderVersion = "0.18.4";
        jre_headless = pkgs.jdk17_headless;
      };
      symlinks = {
        "mods" = "${modpack}/mods";
      };

      extraStartPre = ''
        # Some previous starts may have left a plain "config" file behind.
        # Performance mods need a writable config directory to boot.
        if [ -f config ]; then
          rm -f config
        fi
        mkdir -p config
      '';

      jvmOpts = "-Xms4G -Xmx8G";

      serverProperties = {
        motd = "Creabblemon";
        max-players = 10;
        online-mode = false;
        server-port = creabblemonPort;
        view-distance = 18;
        enforce-secure-profile = false;
      };
    };
  };

  # services.tailscale.serve.services.mc-creabblemon.endpoints."tcp:${creabblemonPortStr}" =
  #   "http://localhost:${creabblemonPortStr}";
}
