{
  self,
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  fqdn = "hass.${config.vars.domainName}";
  serverIP = config.vars.staticIP;
  serverIPv6 = "2001:861:3884:4fd0:8ceb:7d56:bf25:5a17";
  hassPort = config.services.home-assistant.config.http.server_port;
  massFqdn = "mass.${config.vars.domainName}";
  massWebPort = 8095;
in
{
  networking.firewall.extraCommands = ''
    # Thread
    ${lib.openTCPPortForLAN 8081}
    ${lib.openTCPPortForLAN 8082}
    # Music Assistant
    ${lib.openTCPPortForLAN massWebPort} # web interface
    ${lib.openTCPPortForLAN 8097} # web socket
    # Squeezlite
    ${lib.openTCPPortForLAN 3483}
    ${lib.openUDPPortForLAN 3483}
    ${lib.openTCPPortForLAN 9090}
    # Spotify Connect & more (ephemeral ports)
    ${lib.openTCPPortRangeForLAN 32768 65535}
    ${lib.openUDPPortRangeForLAN 32768 65535}
  '';

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
        extended_openai_conversation
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
          external_url = "https://${fqdn}";
          internal_url = "http://${serverIP}:${builtins.toString hassPort}";
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

    music-assistant = {
      enable = true;
      providers = [
        "hass"
        "hass_players"
        "spotify"
        "spotify_connect"
        "squeezelite"
        "sendspin"
      ];
    };

    matter-server = {
      enable = true;
    };

    openthread-border-router = {
      enable = true;
      package = inputs.otbr.legacyPackages.${pkgs.stdenv.hostPlatform.system}.openthread-border-router;
      backboneInterface = "eth0";
      rest.listenAddress = "::";
      web = {
        enable = true;
        listenAddress = "::";
      };
      radio = {
        device = "/dev/serial/by-id/usb-Nabu_Casa_Home_Assistant_Connect_ZBT-1_a47f43e6f769ef11bee8a976d9b539e6-if00-port0";
        baudRate = 460800;
        flowControl = false;
      };
    };

    wyoming = {
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
  };

  services.traefik.dynamicConfigOptions.http = rec {
    # HA
    routers.to-hass = {
      rule = "Host(`${fqdn}`)";
      service = "hass";
    };
    services."${routers.to-hass.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString hassPort}";
      }
    ];

    # MA
    routers.to-mass = {
      rule = "Host(`${massFqdn}`)";
      service = "mass";
    };
    services."${routers.to-mass.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString massWebPort}";
      }
    ];
  };

  services.restic.backups.opt.paths = [ config.services.home-assistant.configDir ];
}
