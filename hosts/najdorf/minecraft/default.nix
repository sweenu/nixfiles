{ config, pkgs, lib, ... }:

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

  services.restic = {
    backups.minecraft = {
      initialize = true;
      repository = "sftp:root@grunfeld:/data/backups/minecraft";
      paths = [ "/opt/minecraft" ];
      pruneOpts = [ "--keep-last 36" "--keep-daily 14" "--keep-weekly 12" ];
      timerConfig = { OnCalendar = "*-*-* *:00:00"; RandomizedDelaySec = "5m"; };
      passwordFile = config.age.secrets.resticPassword.path;
      backupCleanupCommand = "${pkgs.curl}/bin/curl https://hc-ping.com/15b910b0-7414-42d8-87b7-d819ec676293";
    };
  };
}
