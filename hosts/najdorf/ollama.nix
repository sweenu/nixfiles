{ ... }:

{
  virtualisation.arion.projects.ollama.settings = {
    services.ollama.service = {
      image = "ollama/ollama";
      container_name = "ollama";
      volumes = [ "ollama:/root/.ollama" ];
      environment = {
        OLLAMA_HOST = "0.0.0.0";
      };
    };

    docker-compose.volumes = {
      ollama = { };
    };
  };
}
