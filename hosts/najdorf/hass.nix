{ self, config, pkgs, inputs, ... }:

{
  # Till https://github.com/NixOS/nixpkgs/pull/444238
  systemd.services.music-assistant.path = [ pkgs.librespot-ma ];
  networking.firewall =
    let
      openTCPPortForLAN = port: "iptables -I INPUT -p tcp -s 192.168.1.0/24 --dport ${builtins.toString port} -j ACCEPT";
      openUDPPortForLAN = port: "iptables -I INPUT -p udp -s 192.168.1.0/24 --dport ${builtins.toString port} -j ACCEPT";
    in
    {
      extraCommands = ''
        ${openTCPPortForLAN 8081} # Thread
        ${openTCPPortForLAN 8082} # Thread
        ${openTCPPortForLAN 8095} # MA web interface
        ${openTCPPortForLAN 8097} # MA web socket
        ${openTCPPortForLAN 3483} # Squeezelite
        ${openUDPPortForLAN 3483} # Squeezelite
      '';
    };

  age.secrets = {
    hassSecretsYaml = rec {
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
        "isal" # fast compression
        "matter"
        "music_assistant"
        "ollama"
        "otbr"
        "overkiz" # needed for somfy
        "somfy"
        "thread"
        "wyoming"
      ];
      config = {
        default_config = { };
        automation = "!include automations.yaml";
        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          temperature_unit = "C";
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


}
