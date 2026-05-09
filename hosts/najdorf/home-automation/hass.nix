{
  self,
  config,
  pkgs,
  ...
}:

let
  serverIP = config.vars.staticIP;
  serverIPv6 = "2001:861:3884:4fd0:8ceb:7d56:bf25:5a17";
in
{
  age.secrets = {
    hassSecretsYaml = {
      file = "${self}/secrets/hass/secrets.age";
      path = "${config.services.home-assistant.configDir}/secrets.yaml";
      owner = config.systemd.services.home-assistant.serviceConfig.User;
      group = config.systemd.services.home-assistant.serviceConfig.Group;
      mode = "600";
    };
  };

  services = {
    home-assistant = {
      enable = true;
      extraComponents = [
        "anthropic"
        "apple_tv" # looks for it for some reason
        "default_config"
        "esphome"
        "google"
        "google_translate" # TTS fallback for wyoming-piper
        "improv_ble"
        "isal" # fast compression
        "ipp"
        "matter"
        "met"
        "meteo_france"
        "music_assistant"
        "open_router"
        "otbr"
        "overkiz" # needed for somfy
        "shelly"
        "somfy"
        "spotify"
        "thread"
        "upnp"
        "wyoming"
      ];
      customComponents = with pkgs; [
        bbox
        dawarich-ha
        home-assistant-custom-components.adaptive_lighting
        openai-whisper-cloud
      ];
      config = {
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          temperature_unit = "C";
        };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
            serverIP
            "::1"
            serverIPv6
          ];
        };

        # Default config except `backup`, `cloud`, `go2rtc`
        assist_pipeline = { };
        bluetooth = { };
        config = { };
        conversation = { };
        dhcp = { };
        energy = { };
        history = { };
        homeassistant_alerts = { };
        image_upload = { };
        logbook = { };
        media_source = { };
        mobile_app = { };
        my = { };
        ssdp = { };
        stream = { };
        sun = { };
        usage_prediction = { };
        usb = { };
        webhook = { };
        zeroconf = { };
      };
      configWritable = true;
      openFirewall = true;
    };

    matter-server = {
      enable = true;
    };
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services = {
  #   hass.https."443" = "http://localhost:${builtins.toString config.services.home-assistant.config.http.server_port}";
  # };

  services.restic.backups.opt.paths = [ config.services.home-assistant.configDir ];
}
