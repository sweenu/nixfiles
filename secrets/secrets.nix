let
  carokann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";
  najdorfHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKpdd19cjYDViCu9mLhbMwf33ohOYXEEqg32MY9SP6s root@najdorf";
  grunfeldHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpAQMxLYp8mkj0EoH7tDw/irV9SirToX8XvzKW3ikSs root@grunfeld";
in
{
  # najdorf
  "smtp_password.age".publicKeys = [ carokann najdorfHost ];
  "hercules-ci/binary-caches.json.age".publicKeys = [ carokann najdorfHost ];
  "hercules-ci/cluster-join-token.key.age".publicKeys = [ carokann najdorfHost ];
  "restic_password.age".publicKeys = [ carokann najdorfHost ];
  "traefik/env.age".publicKeys = [ carokann najdorfHost ];
  "authelia/jwt_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/session_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/storage_encryption_key.age".publicKeys = [ carokann najdorfHost ];
  "authelia/users.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/env.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/admin_user.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/admin_password.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/db_password.age".publicKeys = [ carokann najdorfHost ];
  "searx/env.age".publicKeys = [ carokann najdorfHost ];
  "n8n/env.age".publicKeys = [ carokann najdorfHost ];
  "ig_story_fetcher_config.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/db_password.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/matrix_key.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/server_crt.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/server_key.age".publicKeys = [ carokann najdorfHost ];
  "obsidian-livesync/env.age".publicKeys = [ carokann najdorfHost ];
  "wordpress/db_password.age".publicKeys = [ carokann najdorfHost ];
  "vrising_discord_bot/bot_token.age".publicKeys = [ carokann najdorfHost ];
  "vrising_discord_bot/portainer_access_key.age".publicKeys = [ carokann najdorfHost ];
  "immich/env.age".publicKeys = [ carokann najdorfHost ];

  # grunfeld
  "snapserver/env_file.age".publicKeys = [ carokann grunfeldHost ];
  "3proxy_users.age".publicKeys = [ carokann grunfeldHost ];
}
