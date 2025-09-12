{
  services.home-assistant = {
    enable = true;
    config = null;
    extraComponents = [ "isal" ];
  };

  services.music-assistant = {
    enable = true;
  };
}
