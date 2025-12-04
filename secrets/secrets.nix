let
  carokann = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyqgAJe9NTMN895kztljIIPYIRExKOdDvB6zroete6Z sweenu@carokann";
  najdorfHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKpdd19cjYDViCu9mLhbMwf33ohOYXEEqg32MY9SP6s root@najdorf";
in
{
  # najdorf
  "smtp_password.age".publicKeys = [ carokann najdorfHost ];
  "restic/password.age".publicKeys = [ carokann najdorfHost ];
  "restic/env.age".publicKeys = [ carokann najdorfHost ];
  "traefik/env.age".publicKeys = [ carokann najdorfHost ];
  "authelia/jwt_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/session_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/storage_encryption_key.age".publicKeys = [ carokann najdorfHost ];
  "authelia/ldap_password.age".publicKeys = [ carokann najdorfHost ];
  "authelia/oidc_hmac_secret.age".publicKeys = [ carokann najdorfHost ];
  "authelia/oidc_jwt_private_key.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/admin_password.age".publicKeys = [ carokann najdorfHost ];
  "nextcloud/secrets.age".publicKeys = [ carokann najdorfHost ];
  "n8n/encryption_key.age".publicKeys = [ carokann najdorfHost ];
  "immich/env.age".publicKeys = [ carokann najdorfHost ];
  "obsidian-livesync/env.age".publicKeys = [ carokann najdorfHost ];
  "obsidian-share-note/env.age".publicKeys = [ carokann najdorfHost ];
  "fastmail/app_password.age".publicKeys = [ carokann najdorfHost ];
  "lldap/jwt_secret.age".publicKeys = [ carokann najdorfHost ];
  "lldap/ldap_user_pass.age".publicKeys = [ carokann najdorfHost ];
  "lldap/server_key.age".publicKeys = [ carokann najdorfHost ];
  "grist/env.age".publicKeys = [ carokann najdorfHost ];
  "grist/oidc_client_secret_digest.age".publicKeys = [ carokann najdorfHost ];
  "hass/secrets.age".publicKeys = [ carokann najdorfHost ];
  "dawarich/secret_key_base.age".publicKeys = [ carokann najdorfHost ];
  "dawarich/oidc_client_secret_digest.age".publicKeys = [ carokann najdorfHost ];
  "dawarich/oidc_client_secret_env.age".publicKeys = [ carokann najdorfHost ];
}
