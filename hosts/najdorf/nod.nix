{ self, config, ... }:

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
    ];
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.nod.https."443" =
  #   "http://localhost:${builtins.toString config.services.nod.port}";
}
