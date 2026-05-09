{ lib, ... }:

{
  networking.firewall.extraCommands = ''
    ${lib.openTCPPortForLAN 8081}
    ${lib.openTCPPortForLAN 8082}
  '';

  services = {
    openthread-border-router = {
      enable = true;
      backboneInterfaces = [ "eth0" ];
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

    avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    journal-brief.settings.exclusions = [
      {
        SYSLOG_IDENTIFIER = [ "otbr-agent" ];
        MESSAGE = [ "/.*\\[W\\].*/" ];
      }
    ];
  };
}
