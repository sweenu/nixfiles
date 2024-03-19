{ pkgs, lib, ... }:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://gitlab.com/Sweenu/sweenus-mix/-/raw/fabric/pack.toml";
    packHash = "sha256-Utmz6fe70bDPLQPc/aXncw7VYuxfvzHQa2KSJh/ZeMo=";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";
in
{
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/opt/minecraft";

    servers.sweenus-mix = {
      enable = true;
      package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
      symlinks = {
        "mods" = "${modpack}/mods";
        "ops.json".value = [{
          name = "Sweenu";
          uuid = "c82b7a02-2a70-49fa-94b4-d23efbeebf8b";
          level = 4;
        }];
      };
      serverProperties = {
        difficulty = "normal";
        whitelist = true;
        enforce-whitelist = true;
      };
    };
  };
}
