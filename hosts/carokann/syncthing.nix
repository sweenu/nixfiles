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
    openDefaultPorts = true;
    cert = config.age.secrets.syncthingCert.path;
    key = config.age.secrets.syncthingKey.path;
    settings = {
      devices.najdorf.id = "PZSH5JF-CWSPPB5-2PUGMGW-VTAZISB-WF4LKLW-U6Z3ABC-INV6QD5-GFHYDA4";
      folders.notes = {
        path = "${config.vars.home}/${config.vars.documentsFolder}/notes/synced";
        devices = [ "najdorf" ];
      };
    };
  };
}
