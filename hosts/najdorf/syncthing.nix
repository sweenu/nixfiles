{
  self,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.syncthing;
  notes = "${cfg.dataDir}/notes";
in
{
  age.secrets = {
    syncthingCert.file = "${self}/secrets/syncthing/najdorf-cert.age";
    syncthingKey.file = "${self}/secrets/syncthing/najdorf-key.age";
  };

  services.syncthing = {
    enable = true;
    cert = config.age.secrets.syncthingCert.path;
    key = config.age.secrets.syncthingKey.path;
    settings = {
      devices = {
        carokann.id = "JBSKLWD-GDNKAIZ-DRGZWWI-B6W3BTZ-GBXKRL5-XM6WZDF-QK7WZCP-223KUAL";
        phone.id = "TTT2EL5-JWBLEYS-IJNDMBV-WKASVUI-HKSG6VO-BIIV3HD-M42DHCS-AMJBOAD";
      };
      folders.notes = {
        path = notes;
        devices = [
          "carokann"
          "phone"
        ];
      };
    };
  };

  systemd.services.notes-history = {
    description = "Snapshot the Obsidian notes in git";
    startAt = "*:0/5";
    path = [ pkgs.git ];
    environment = {
      GIT_DIR = "${cfg.dataDir}/notes.git";
      GIT_WORK_TREE = notes;
    };
    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
    };
    script = ''
      [ -f "$GIT_DIR/HEAD" ] || git init -q
      printf '%s\n' .stfolder '.syncthing.*.tmp' > "$GIT_DIR/info/exclude"
      git add -A
      git diff --cached --quiet || git -c user.name=notes-history -c user.email=notes-history@najdorf commit -qm snapshot
    '';
  };

  services.restic.backups.opt.paths = [ cfg.dataDir ];
}
