{
  self,
  config,
  ...
}:

let
  # Base topic configured in the TICMeter web UI, minus the per-device suffix
  # (the default is TICMeter/<device id>). Case-sensitive: a mismatch means the
  # device connects but its publishes are silently dropped.
  ticmeterTopic = "TICMeter";
in
{
  age.secrets = {
    "mosquitto/hass".file = "${self}/secrets/mosquitto/hass.age";
    "mosquitto/ticmeter".file = "${self}/secrets/mosquitto/ticmeter.age";
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = config.vars.staticIP;
        port = 1883;
        users = {
          hass = {
            passwordFile = config.age.secrets."mosquitto/hass".path;
            acl = [ "readwrite #" ];
          };
          ticmeter = {
            passwordFile = config.age.secrets."mosquitto/ticmeter".path;
            acl = [
              "readwrite homeassistant/#"
              "readwrite ${ticmeterTopic}/#"
            ];
          };
        };
      }
    ];
  };

  services.restic.backups.opt.paths = [ config.services.mosquitto.dataDir ];
}
