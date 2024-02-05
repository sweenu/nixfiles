let
  carokann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";
  najdorfHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKpdd19cjYDViCu9mLhbMwf33ohOYXEEqg32MY9SP6s root@najdorf";
  grunfeldHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpAQMxLYp8mkj0EoH7tDw/irV9SirToX8XvzKW3ikSs root@grunfeld";
in
{
  # carokann
  "scw_conf.age".publicKeys = [ carokann ];

  # najdorf
  "najdorf_root_key.age".publicKeys = [ carokann najdorfHost ];
  "smtp_password.age".publicKeys = [ carokann najdorfHost ];
  "hercules-ci/binary-caches.json.age".publicKeys = [ carokann najdorfHost ];
  "hercules-ci/cluster-join-token.key.age".publicKeys = [ carokann najdorfHost ];
  "traefik/env.age".publicKeys = [ carokann najdorfHost ];
  "authelia/jwt_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/session_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/storage_encryption_key.age".publicKeys = [ carokann najdorfHost ];
  "authelia/users.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/env.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/admin_user.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/admin_password.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/db_password.age".publicKeys = [ carokann najdorfHost ];
  "restic/nextcloud.age".publicKeys = [ carokann najdorfHost ];
  "restic/calibre.age".publicKeys = [ carokann najdorfHost ];
  "searx/env.age".publicKeys = [ carokann najdorfHost ];
  "n8n/env.age".publicKeys = [ carokann najdorfHost ];
  "ig_story_fetcher_config.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/db_password.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/matrix_key.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/server_crt.age".publicKeys = [ carokann najdorfHost ];
  "dendrite/server_key.age".publicKeys = [ carokann najdorfHost ];

  # grunfeld
  "snapserver/env_file.age".publicKeys = [ carokann grunfeldHost ];
  "3proxy_users.age".publicKeys = [ carokann grunfeldHost ];
}
