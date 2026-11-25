{ self, config, ... }:

{
  age.secrets = {
    syncthingCert.file = "${self}/secrets/syncthing/carokann-cert.age";
    syncthingKey.file = "${self}/secrets/syncthing/carokann-key.age";
  };

  services.syncthing = {
    enable = true;
    user = config.vars.username;
    group = "users";
    dataDir = config.vars.home;
    cert = config.age.secrets.syncthingCert.path;
    key = config.age.secrets.syncthingKey.path;
    settings = {
      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      devices.najdorf = {
        id = "PZSH5JF-CWSPPB5-2PUGMGW-VTAZISB-WF4LKLW-U6Z3ABC-INV6QD5-GFHYDA4";
        addresses = [ "tcp://syncthing.${config.vars.tailnetName}:22000" ];
      };
      folders.notes = {
        path = "${config.vars.home}/${config.vars.documentsFolder}/notes/synced";
        devices = [ "najdorf" ];
      };
    };
  };
}
