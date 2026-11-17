{
  self,
  config,
  pkgs,
  ...
}:

let
  # Benchmarked against q5_0, medium and large-v3: best accuracy on casual French,
  # ~7s per minute of audio on carokann's 840M through Vulkan.
  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
    hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
  };
in
{
  age.secrets.beeperMinusMcpToken = {
    file = "${self}/secrets/beeper-minus/mcp_token.age";
    owner = "beeper";
  };

  services.beeper-server.enable = true;

  services.beeper-minus = {
    enable = true;
    whisperPackage = pkgs.whisper-cpp-vulkan;
    settings = {
      # tailscale serve passes the name the app was opened with along.
      web = {
        allowed_hosts = [ "beeper.${config.vars.tailnetName}" ];
        allowed_users = [ "brunoinec@gmail.com" ];
        mcp = true;
        mcp_token_file = config.age.secrets.beeperMinusMcpToken.path;
      };
      transcription = {
        auto = true;
        notes_to_self = true;
        engine = "whisper-cpp";
        whisper-cpp = {
          model = "${model}";
          languages = [
            "fr"
            "en"
          ];
        };
      };
    };
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services = {
  #   beeper.https."443" = "http://localhost:${builtins.toString config.services.beeper-minus.settings.web.port}";
  # };
}
