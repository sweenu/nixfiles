let
  coreKeeperDir = "/opt/coreKeeper";
in
{
  virtualisation.arion.projects.core-keeper.settings = {
    services.core-keeper.service = {
      image = "escaping/core-keeper-dedicated";
      container_name = "core-keeper";
      stop_grace_period = "2m";
      volumes = [
        "${coreKeeperDir}/files:/home/steam/core-keeper-dedicated"
        "${coreKeeperDir}/data:/home/steam/core-keeper-data"
      ];
    };
  };
}
