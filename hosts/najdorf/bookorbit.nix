{
  self,
  config,
  lib,
  ...
}:

let
  fqdn = "bookorbit.${config.vars.tailnetName}";
  publicFqdn = "bookorbit.${config.vars.domainName}";
  port = 3000;

  stateDir = "/var/lib/bookorbit";
  booksDir = "${stateDir}/books";
  dataDir = "${stateDir}/data";
  importsDir = "${stateDir}/imports";

  user = "bookorbit";
  # Static so PUID/PGID can be resolved at eval time; peer auth needs the
  # container's uid to map back to this account on the host.
  id = 3000;

  database = "bookorbit";
  socketDir = "/run/postgresql";

  # The container talks to the host cluster over the bind-mounted socket, so
  # peer auth applies: postgres resolves the caller's uid through the host's
  # /etc/passwd, which is why PUID must match the `bookorbit` system user.
  # pg-connection-string (pinned to 2.14.0 upstream) turns the `host` query
  # parameter into a socket directory, so no password is involved.
  databaseUrl = "postgres://${user}@/${database}?host=${socketDir}";

  # migrate.js issues `CREATE EXTENSION IF NOT EXISTS` for each of these, which
  # would need superuser. Creating them here first makes those statements
  # no-ops (the IF NOT EXISTS shortcut returns before the permission check), so
  # the bookorbit role stays unprivileged.
  extensions = [
    "uuid-ossp"
    "pg_trgm"
    "unaccent"
    "vector"
  ];
in
{
  age.secrets."bookorbit/env".file = "${self}/secrets/bookorbit/env.age";

  users.users.${user} = {
    uid = id;
    group = user;
    isSystemUser = true;
  };
  users.groups.${user}.gid = id;

  # Docker creates missing bind-mount sources as root, and entrypoint.sh only
  # chowns paths under /data, explicitly skipping everything else. So the
  # library would stay root-owned while the app runs as `id`: readable, but
  # uploads and file renames fail at write time rather than at startup.
  systemd.tmpfiles.settings."10-bookorbit".${booksDir}.d = {
    inherit user;
    group = user;
    mode = "0755";
  };

  services.postgresql = {
    extensions = ps: [ ps.pgvector ];
    ensureDatabases = [ database ];
    ensureUsers = [
      {
        name = user;
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.bookorbit-postgres-extensions = {
    description = "Create the PostgreSQL extensions BookOrbit expects";
    after = [ "postgresql-setup.service" ];
    requires = [ "postgresql-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
    };
    script = lib.concatMapStringsSep "\n" (extension: ''
      ${lib.getExe' config.services.postgresql.package "psql"} \
        --dbname=${database} \
        --command='CREATE EXTENSION IF NOT EXISTS "${extension}"'
    '') extensions;
  };

  # migrate.js runs at container start, so the cluster and its extensions have
  # to be there first.
  systemd.services.arion-bookorbit = {
    after = [ "bookorbit-postgres-extensions.service" ];
    requires = [ "bookorbit-postgres-extensions.service" ];
  };

  virtualisation.arion.projects.bookorbit.settings = {
    services.bookorbit = {
      service = {
        image = "ghcr.io/bookorbit/bookorbit:2.8.1";
        container_name = "bookorbit";
        restart = "unless-stopped";
        # JWT_SECRET, SETUP_BOOTSTRAP_TOKEN, EMAIL_ENCRYPTION_KEY and
        # MIGRATION_ENCRYPTION_KEY.
        env_file = [ config.age.secrets."bookorbit/env".path ];
        ports = [ "127.0.0.1:${toString port}:${toString port}" ];
        volumes = [
          "${booksDir}:/books"
          "${dataDir}:/data"
          "${importsDir}:/imports:ro"
          "${socketDir}:${socketDir}"
        ];
        tmpfs = [ "/tmp" ];
        environment = {
          NODE_ENV = "production";
          TZ = config.vars.timezone;
          PORT = toString port;
          DATABASE_URL = databaseUrl;
          APP_URL = "https://${fqdn}";
          PUID = toString id;
          PGID = toString id;
          # Keep the library folder picker from browsing the container root.
          LIBRARY_BROWSE_ROOT = "/books";
          MIGRATION_IMPORT_ROOT = "/imports";
          OIDC_ALLOW_LOCAL_ISSUERS = "true";
        };
        # The daemon-wide DNS is public resolvers only, so MagicDNS names don't
        # resolve in containers. Put the tailnet resolver first and keep the
        # public ones as fallback: it forwards anything non-tailnet upstream,
        # but a plain SERVFAIL shouldn't cost us metadata lookups.
        dns = [ "100.100.100.100" ] ++ config.vars.dnsResolvers;
        # entrypoint.sh chowns /data and drops to PUID:PGID before exec'ing node.
        capabilities = {
          ALL = false;
          CHOWN = true;
          DAC_OVERRIDE = true;
          FOWNER = true;
          SETGID = true;
          SETUID = true;
        };
        stop_grace_period = "30s";
      };
      # Compose keys arion has no option for.
      out.service = {
        init = true;
        read_only = true;
        security_opt = [ "no-new-privileges:true" ];
      };
    };
  };

  services.restic.backups.opt.paths = [ stateDir ];

  services.traefik.dynamicConfigOptions.http = rec {
    routers.to-bookorbit = {
      # A Kobo can't reach the tailnet, so the endpoints it talks to have to be
      # public. The device token in the path is the credential, so only
      # token-scoped routes are exposed; /api/v3 and /api/UserStorage are the
      # reading-services paths the device hits at the host root (the app keeps
      # them out of its /api/v1 prefix). The token-less management routes under
      # /api/v1/kobo stay tailnet-only.
      rule = "Host(`${publicFqdn}`) && (PathPrefix(`/api/v1/kobo/`) || PathPrefix(`/api/v3/`) || PathPrefix(`/api/UserStorage/`)) && !PathRegexp(`^/api/v1/kobo/(devices|settings|history)(/|$)`)";
      service = "bookorbit";
    };
    services."${routers.to-bookorbit.service}".loadBalancer.servers = [
      {
        url = "http://localhost:${builtins.toString port}";
      }
    ];
  };

  # services.tailscale.serve.services.bookorbit.endpoints."tcp:443" =
  #   "http://localhost:${builtins.toString port}";
}
