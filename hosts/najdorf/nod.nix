{ self, config, ... }:

let
  notes = "${config.services.nod.dataDir}/workspace/notes";
  syncthing = config.services.syncthing;
  syncedNotes = "${syncthing.dataDir}/notes";
in
{
  # NOD_AUTH_TOKEN (what the web and desktop apps ask for) and NOD_VAULT_KEY,
  # without which the saved credentials in the database can't be decrypted.
  age.secrets."nod/env".file = "${self}/secrets/nod/env.age";

  services.nod = {
    enable = true;
    publicUrl = "https://nod.${config.vars.tailnetName}";
    environmentFile = config.age.secrets."nod/env".path;
    environment = {
      NOD_ANALYTICS_ENABLED = "false";
      NOD_FEEDBACK_ENABLED = "false";
      NOD_TRACES_URL = "";
      NOD_ONBOARDING_EMAIL_URL = "";
    };
  };

  # Conversations, memory, schedules and the encrypted credentials are in
  # PostgreSQL, already covered by postgresqlBackup. This is the rest: the
  # integration identity, transcripts and keys, plus the sandboxes' files and
  # browser profiles.
  services.restic.backups.opt = {
    paths = [
      "/var/lib/nod"
      config.services.nod.dataDir
    ];
    exclude = [
      # Downloaded Whisper and Kokoro models.
      "/var/lib/nod/speech"
      # Rolling 24 h diagnostic journal, only read by "Report a problem".
      "/var/lib/nod/feedback-logs"
      # The bindfs view of the workspace sandbox, already backed up via dataDir.
      "/var/lib/nod/workspaces"
      notes
    ];
  };

  # The Syncthing notes, shown to the sandbox as its own files (uid 1000).
  fileSystems.${notes} = {
    device = syncedNotes;
    fsType = "fuse.bindfs";
    noCheck = true;
    options = [
      "map=${syncthing.user}/1000:@${syncthing.group}/@1000"
      "nofail"
    ];
  };

  # bindfs fails on a missing source, and Syncthing only creates it once running.
  system.activationScripts.nod-notes = {
    deps = [ "users" ];
    text = "install -d -m 700 -o ${syncthing.user} -g ${syncthing.group} ${syncedNotes}";
  };

  # The container only sees mounts that exist when it starts.
  systemd.services.arion-nod.unitConfig.WantsMountsFor = [ notes ];

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.nod.https."443" =
  #   "http://localhost:${builtins.toString config.services.nod.port}";
}
