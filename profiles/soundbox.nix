{
  config,
  pkgs,
  ...
}:
{
  # WiFi Configuration
  #
  # QUICK START: Uncomment and edit one of these options:
  #
  # Option 1 (Simple): Edit directly here - WARNING: password visible in config!
  # networking.wireless.networks."YourWiFiName".psk = "your-password";
  #
  # Option 2 (Secure): Use agenix secrets - see WIFI-SETUP.md
  # Option 3 (Manual): Boot with Ethernet, configure via SSH - see WIFI-SETUP.md

  networking.wireless = {
    enable = true;

    # Declarative WiFi networks (passwords visible in Nix store)
    networks = {
      # Uncomment and edit:
      # "YourNetworkName" = {
      #   psk = "your-wifi-password";
      # };

      # Multiple networks example:
      # "HomeWiFi" = {
      #   psk = "home-password";
      #   priority = 10;  # Higher priority
      # };
      # "WorkWiFi" = {
      #   psk = "work-password";
      #   priority = 5;
      # };
    };

    # For hidden networks, add:
    # "HiddenNetwork" = {
    #   psk = "password";
    #   hidden = true;
    # };
  };
  # Enable Bluetooth - configured to be discoverable from phones with PIN security
  bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Discoverable = true;
        DiscoverableTimeout = 0;
        Pairable = true;
        PairableTimeout = 0;
        # Set device class to Audio/Video (Loudspeaker)
        Class = "0x240414";
        # Device name visible to phones
        Name = "SoundBox";
      };
      Policy = {
        # Auto-connect A2DP and AVRCP profiles
        AutoEnable = true;
      };
    };
  };

  # Raspberry Pi specific configuration
  raspberry-pi."4" = {
    # Disable default audio to use HiFiBerry
    audio.enable = false;
  };

  # HiFiBerry AMP2 configuration
  # The HiFiBerry AMP2 uses the same driver as DAC+
  hardware.deviceTree = {
    overlays = [
      {
        name = "hifiberry-dacplus";
        dtboFile = "${pkgs.raspberrypifw}/share/raspberry-pi/boot/overlays/hifiberry-dacplus.dtbo";
      }
    ];
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = false;
    };
    pulse.enable = true;
  };

  # Volume limit configuration
  environment.etc."alsa/conf.d/99-volumelimit.conf".text =
    let
      volumeLimit = 80; # Set to a safe level for your speakers
    in
    ''
      # Limit maximum volume to ${toString volumeLimit}%
      pcm.!default {
        type plug
        slave.pcm "volumelimit"
      }

      pcm.volumelimit {
        type softvol
        slave.pcm "plughw:0,0"
        control {
          name "SoftMaster"
          card 0
        }
        max_dB ${toString (volumeLimit - 100)}.0
        resolution 256
      }
    '';

  # PipeWire volume limit enforcement
  services.pipewire.extraConfig.pipewire =
    let
      volumeLimit = 80; # Must match the ALSA limit above
    in
    {
      "99-volume-limit" = {
        "context.properties" = {
          "default.clock.allowed-rates" = [
            44100
            48000
            88200
            96000
          ];
        };
        "stream.properties" = {
          "channelmix.max-volume" = volumeLimit / 100.0;
        };
      };
    };

  # Service to enforce volume limit on boot
  systemd.services.volume-limit =
    let
      volumeLimit = 80; # Must match the limits above
    in
    {
      description = "Enforce Volume Limit";
      after = [
        "sound.target"
        "pipewire.service"
        "alsa-restore.service"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Wait for audio system to be ready
        ${pkgs.coreutils}/bin/sleep 3

        # Set ALSA volume to limit (0-100 scale)
        ${pkgs.alsa-utils}/bin/amixer -q sset Master ${toString volumeLimit}% 2>/dev/null || true
        ${pkgs.alsa-utils}/bin/amixer -q sset PCM ${toString volumeLimit}% 2>/dev/null || true
        ${pkgs.alsa-utils}/bin/amixer -q sset Digital ${toString volumeLimit}% 2>/dev/null || true

        # Set soft volume control
        ${pkgs.alsa-utils}/bin/amixer -q sset SoftMaster ${toString volumeLimit}% 2>/dev/null || true

        echo "Volume limit set to ${toString volumeLimit}%"
      '';
    };

  # Bluetooth PIN pairing agent
  # This requires devices to enter a PIN code when pairing

  # Create PIN agent script
  environment.etc."bluetooth/pin-agent.sh" = {
    text = ''
      #!/bin/sh
      # Simple PIN agent - always returns the same PIN
      # Change this PIN to something more secure
      PIN="1234"

      echo "$PIN"
    '';
    mode = "0755";
  };

  # Bluetooth PIN pairing agent service
  systemd.services.bluetooth-pin-agent = {
    description = "Bluetooth PIN Pairing Agent";
    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bluez-tools}/bin/bt-agent --capability=DisplayYesNo --pin-code=1234";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Ensure Bluetooth audio modules are loaded and discoverable
  systemd.services.bluetooth.serviceConfig = {
    ExecStartPost = [
      "${pkgs.coreutils}/bin/sleep 2"
      "${pkgs.bluez}/bin/bluetoothctl discoverable on"
      "${pkgs.bluez}/bin/bluetoothctl pairable on"
    ];
  };

  services.sendspin = {
    enable = true;
    clientName = "SoundBox";
    logLevel = "INFO";
    # Adjust delay if needed for better sync
    # staticDelayMs = -100;
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    bluez
    bluez-tools
  ];
}
