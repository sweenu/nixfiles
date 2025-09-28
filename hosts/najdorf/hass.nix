{ self, config, pkgs, inputs, lib, ... }:

let
  fqdn = "hass.${config.vars.domainName}";
  serverIP = "192.168.1.41";
  hassPort = config.services.home-assistant.config.http.server_port;
  massWebPort = 8095;
in
{
  # Till https://github.com/NixOS/nixpkgs/pull/444238
  systemd.services.music-assistant.path = lib.mkForce (with pkgs; [ lsof librespot-ma ]);
  networking.firewall.extraCommands = ''
    ${lib.openTCPPortForLAN 8081} # Thread
    ${lib.openTCPPortForLAN 8082} # Thread
    ${lib.openTCPPortForLAN massWebPort} # MA web interface
    ${lib.openTCPPortForLAN 8097} # MA web socket
    ${lib.openTCPPortForLAN 3483} # Squeezelite
    ${lib.openUDPPortForLAN 3483} # Squeezelite
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
        "esphome"
        "google"
        "google_translate" # TTS fallback for wyoming-piper
        "isal" # fast compression
        "ipp"
        "matter"
        "met"
        "music_assistant"
        "open_router"
        "otbr"
        "overkiz" # needed for somfy
        "somfy"
        "thread"
        "wyoming"
      ];
      config = {
        default_config = { };
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
          trusted_proxies = [ "127.0.0.1" serverIP ];
        };
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
      ];
    };

    matter-server = {
      enable = true;
    };

    openthread-border-router = {
      enable = false;
      package = inputs.nixpkgs-otbr.legacyPackages.${pkgs.system}.openthread-border-router;
      backboneInterface = "enp192s0f3u1";
      rest.listenAddress = "0.0.0.0";
      web.listenAddress = "0.0.0.0";
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
          voice = "en_GB-jenny_dioco-medium";
          uri = "tcp://0.0.0.0:10200";
          useCUDA = false;
        };
      };
      faster-whisper = {
        servers.main = {
          enable = true;
          model = "base";
          language = "en";
          uri = "tcp://0.0.0.0:10300";
        };
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-hass = {
      rule = "Host(`${fqdn}`)";
      service = "hass";
    };
    services."${routers.to-hass.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString hassPort}";
      }
    ];
    routers.to-mass = {
      rule = "Host(`mass.${config.vars.domainName}`)";
      service = "mass";
    };
    services."${routers.to-mass.service}".loadBalancer.servers = [
      {
        url = "http://127.0.0.1:${builtins.toString massWebPort}";
      }
    ];
  };

}
