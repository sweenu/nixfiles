let
  carokann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";
  benoniHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL0bFwpJXdt7vxT82aeMZhfwF5i0DEXaWT3SH2TzxIX root@benoni";
  grunfeldHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpAQMxLYp8mkj0EoH7tDw/irV9SirToX8XvzKW3ikSs root@grunfeld";
in
{
  # carokann
  "scw_conf.age".publicKeys = [ carokann ];

  # benoni
  "benoni_root_key.age".publicKeys = [ carokann benoniHost ];
  "smtp_password.age".publicKeys = [ carokann benoniHost ];
  "hercules-ci/binary-caches.json.age".publicKeys = [ carokann benoniHost ];
  "hercules-ci/cluster-join-token.key.age".publicKeys = [ carokann benoniHost ];
  "traefik/env.age".publicKeys = [ carokann benoniHost ];
  "authelia/jwt_secret.age".publicKeys = [ carokann benoniHost ];
  "authelia/session_secret.age".publicKeys = [ carokann benoniHost ];
  "authelia/storage_encryption_key.age".publicKeys = [ carokann benoniHost ];
  "authelia/users.age".publicKeys = [ carokann benoniHost ];
  "nextcloud/env.age".publicKeys = [ carokann benoniHost ];
  "nextcloud/admin_user.age".publicKeys = [ carokann benoniHost ];
  "nextcloud/admin_password.age".publicKeys = [ carokann benoniHost ];
  "nextcloud/db_password.age".publicKeys = [ carokann benoniHost ];
  "restic/nextcloud.age".publicKeys = [ carokann benoniHost ];
  "restic/calibre.age".publicKeys = [ carokann benoniHost ];

  # grunfeld
  "snapserver/env_file.age".publicKeys = [ carokann grunfeldHost ];
}
