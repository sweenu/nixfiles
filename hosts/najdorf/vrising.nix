let
  vrisingDir = "/opt/vrising";
in
{
  virtualisation.arion.projects.vrising.settings = {
    services.vrising.service = {
      image = "trueosiris/vrising:winehq";
      container_name = "vrising";
      environment = {
        TZ = "Europe/Paris";
        SERVERNAME = "leserveur";
      };
      ports = [
        "9876:9876/udp"
        "9877:9877/udp"
      ];
      volumes = [
        "${vrisingDir}/server:/mnt/vrising/server"
        "${vrisingDir}/persistentdata:/mnt/vrising/persistentdata"
      ];
    };
  };
}
