{ ... }:

{
  services.wyoming = {
    piper = {
      servers."main" = {
        enable = true;
        zeroconf.enable = false;
        voice = "en_GB-jenny_dioco-medium";
        uri = "tcp://0.0.0.0:10200";
      };
    };
    faster-whisper = {
      servers.main = {
        enable = true;
        model = "small";
        language = "en";
        uri = "tcp://0.0.0.0:10300";
      };
    };
  };
}
