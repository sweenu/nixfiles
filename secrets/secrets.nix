let
  carokann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKg9NXu70s3AO2GbpzTBGleZVaCmGZn6HscelaYrnFnt";
  carokannUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z";
  benoni = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGL0bFwpJXdt7vxT82aeMZhfwF5i0DEXaWT3SH2TzxIX";
  carokannKeys = [ carokann carokannUser ];
in
{
  # personal
  "scw_conf.age".publicKeys = carokannKeys;

  # server
  "smtp_password.age".publicKeys = carokannKeys ++ [ benoni ];
  "traefik/env.age".publicKeys = carokannKeys ++ [ benoni ];
  "authelia/jwt_secret.age".publicKeys = carokannKeys ++ [ benoni ];
  "authelia/session_secret.age".publicKeys = carokannKeys ++ [ benoni ];
  "authelia/storage_encryption_key.age".publicKeys = carokannKeys ++ [ benoni ];
  "authelia/users.age".publicKeys = carokannKeys ++ [ benoni ];
  "nextcloud/env.age".publicKeys = carokannKeys ++ [ benoni ];
  "nextcloud/admin_user.age".publicKeys = carokannKeys ++ [ benoni ];
  "nextcloud/admin_password.age".publicKeys = carokannKeys ++ [ benoni ];
  "nextcloud/db_password.age".publicKeys = carokannKeys ++ [ benoni ];

  # restic
  "restic/nextcloud.age".publicKeys = carokannKeys ++ [ benoni ];
}
