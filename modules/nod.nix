{
  config,
  options,
  lib,
  pkgs,
  ...
}:

# Nod's server runs natively; the agent's sandboxes (workspace and browser) are
# the upstream containers. The server never touches the Docker socket: it only
# reaches nod-runtime-proxy, upstream's allowlist that permits nothing but exec
# into those two containers, with fixed users and working directories.
let
  cfg = config.services.nod;

  stateDir = "/var/lib/nod";
  runtimeSocket = "/run/nod-runtime/docker.sock";
  workspaceContainer = "nod-workspace-main";
  browserContainer = "nod-browser-main";
  # A new revision gets new tags, which makes compose build the images again.
  imageTag = cfg.package.src.rev;

  # Every private, reserved and tailnet range: the server itself needs only the
  # internet and loopback (DNS, tailscale serve, unix sockets).
  privateRanges = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "100.64.0.0/10"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "fc00::/7"
    "fe80::/10"
  ];

  proxyScript = pkgs.writeText "nod-runtime-proxy.mjs" ''
    import { createRuntimeProxy } from '${cfg.package.src}/deployment/self-host/docker-proxy.mjs';
    createRuntimeProxy().listen('${runtimeSocket}');
  '';

  sandboxOptions = {
    init = true;
    security_opt = [ "no-new-privileges:true" ];
  };

  # Upstream's iptables sidecar: rejects every private, reserved and tailnet
  # IPv4 range and all IPv6 inside the namespace it shares with a sandbox.
  # cap_drop ALL on the sandbox keeps it from undoing the rules.
  firewall = {
    service = {
      image = "nod-workspace:${imageTag}";
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      user = "root";
      restart = "unless-stopped";
      entrypoint = "/usr/local/bin/nod-workspace-network";
      capabilities = {
        ALL = false;
        NET_ADMIN = true;
      };
      tmpfs = [ "/tmp:size=1m" ];
      healthcheck = {
        test = [
          "CMD"
          "test"
          "-f"
          "/tmp/network-ready"
        ];
        interval = "2s";
        timeout = "3s";
        retries = 10;
      };
    };
    out.service = sandboxOptions // {
      pull_policy = "never";
      read_only = true;
      pids_limit = 32;
      mem_limit = "64m";
    };
  };

  behindFirewall = name: {
    network_mode = "service:${name}";
    depends_on.${name} = {
      condition = "service_healthy";
      restart = true;
    };
  };
in
{
  options.services.nod = {
    enable = lib.mkEnableOption "Nod, n8n's personal agent";

    package = lib.mkPackageOption pkgs "nod-server" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4310;
    };

    publicUrl = lib.mkOption {
      type = lib.types.str;
      example = "https://nod.example.com";
      description = "The exact origin Nod is opened at; the Host header must match it.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nod-sandbox";
      description = "Where the workspace and browser containers keep their files.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Holds NOD_AUTH_TOKEN, NOD_VAULT_KEY and any model or channel keys.";
    };

    environment = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      description = "Extra settings, see https://nod.n8n.io/docs/deploy/configuration/.";
    };
  };

  config = lib.mkIf cfg.enable {
    users = {
      users.nod = {
        isSystemUser = true;
        group = "nod";
        home = stateDir;
      };
      groups.nod = { };
      users.nod-runtime = {
        isSystemUser = true;
        group = "nod-runtime";
        extraGroups = [ "docker" ];
      };
      groups.nod-runtime = { };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "nod" ];
      ensureUsers = [
        {
          name = "nod";
          ensureDBOwnership = true;
        }
      ];
    };

    # The sandboxes run as the image's node user (uid 1000).
    systemd.tmpfiles.settings.nod = {
      "${cfg.dataDir}".d.mode = "0755";
      "${cfg.dataDir}/workspace".d = {
        user = "1000";
        group = "1000";
        mode = "0755";
      };
      "${cfg.dataDir}/workspace-tools".d = {
        user = "1000";
        group = "1000";
        mode = "0700";
      };
      "${cfg.dataDir}/browser".d = {
        user = "1000";
        group = "1000";
        mode = "0700";
      };
    };

    assertions = [
      {
        assertion = options.virtualisation ? arion;
        message = "services.nod runs its sandboxes with arion: import its NixOS module.";
      }
    ];

    # Hosts without arion (the speakers) still load this module.
    virtualisation = lib.optionalAttrs (options.virtualisation ? arion) {
      arion.projects.nod.settings = {
        services = {
          workspace-network = firewall;
          browser-network = firewall;

          workspace = {
            service = {
              build = {
                context = "${cfg.package.src}";
                dockerfile = "Dockerfile.workspace";
              };
              image = "nod-workspace:${imageTag}";
              container_name = workspaceContainer;
              restart = "unless-stopped";
              capabilities.ALL = false;
              volumes = [
                "${cfg.dataDir}/workspace:/workspace"
                "${cfg.dataDir}/workspace-tools:/home/node"
              ];
              command = [
                "sleep"
                "infinity"
              ];
            };
            out.service =
              sandboxOptions
              // behindFirewall "workspace-network"
              // {
                pids_limit = 512;
                mem_limit = "2g";
              };
          };

          browser = {
            service = {
              build = {
                context = "${cfg.package.src}";
                dockerfile = "Dockerfile.browser";
              };
              image = "nod-browser:${imageTag}";
              container_name = browserContainer;
              restart = "unless-stopped";
              capabilities.ALL = false;
              volumes = [ "${cfg.dataDir}/browser:/data" ];
              tmpfs = [
                "/tmp:size=512m"
                "/home/node:uid=1000,gid=1000,mode=700,size=256m"
              ];
              healthcheck = {
                test = [
                  "CMD"
                  "node"
                  "-e"
                  ''const s=require("node:net").connect("/data/control.sock");s.on("connect",()=>{s.end();process.exit(0)});s.on("error",()=>process.exit(1))''
                ];
                interval = "5s";
                timeout = "3s";
                retries = 30;
              };
            };
            # Upstream gives the browser an unfiltered network; here it shares
            # the same firewall as the workspace, so pages can't reach the LAN,
            # the tailnet or this host.
            out.service =
              sandboxOptions
              // behindFirewall "browser-network"
              // {
                read_only = true;
                pids_limit = 1024;
                mem_limit = "3g";
                shm_size = "512m";
              };
          };
        };
      };
    };

    # The server creates thread folders and writes attachments in workspaces/,
    # and commands run there inside the workspace container as the image's
    # node user (uid 1000, pinned by the proxy). Upstream shares one volume
    # between the two; here bindfs shows the container's files to the server
    # as its own. nofail: a missing mount only keeps Nod down, not the boot.
    fileSystems."${stateDir}/workspaces" = {
      device = "${cfg.dataDir}/workspace";
      fsType = "fuse.bindfs";
      noCheck = true;
      options = [
        "map=1000/nod:@1000/@nod"
        "nofail"
      ];
    };

    # arion runs the standalone docker-compose, which doesn't get the plugin
    # path the docker wrapper sets, so it builds without BuildKit and fails on
    # the Dockerfiles' COPY --chmod.
    systemd.services.arion-nod.environment.DOCKER_CLI_PLUGIN_DIRS =
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins";

    systemd.services.nod-runtime-proxy = {
      description = "Allowlisting Docker proxy for Nod";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      environment = {
        WORKSPACE_CONTAINER = workspaceContainer;
        BROWSER_CONTAINER = browserContainer;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.nodejs_24} ${proxyScript}";
        User = "nod-runtime";
        Group = "nod-runtime";
        RuntimeDirectory = "nod-runtime";
        RuntimeDirectoryMode = "0750";
        UMask = "0117";
        Restart = "on-failure";
        PrivateNetwork = true;
        RestrictAddressFamilies = [ "AF_UNIX" ];
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        MemoryMax = "128M";
        TasksMax = 64;
      };
    };

    systemd.services.nod = {
      description = "Nod personal agent server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "postgresql.service"
        "nod-runtime-proxy.service"
        "arion-nod.service"
      ];
      wants = [
        "network-online.target"
        "arion-nod.service"
      ];
      requires = [
        "postgresql.service"
        "nod-runtime-proxy.service"
      ];
      unitConfig.RequiresMountsFor = [ "${stateDir}/workspaces" ];
      environment = {
        NODE_ENV = "production";
        NOD_ENVIRONMENT = "production";
        NOD_HOST = "127.0.0.1";
        PORT = toString cfg.port;
        NOD_PUBLIC_URL = cfg.publicUrl;
        NOD_DATA_ROOT = stateDir;
        DATABASE_URL = "postgresql:///nod?host=/run/postgresql";
        DOCKER_HOST = "unix://${runtimeSocket}";
        DOCKER_CONFIG = "${stateDir}/.docker";
        WORKSPACE_CONTAINER = workspaceContainer;
        BROWSER_CONTAINER = browserContainer;
        NOD_WEB_ROOT = "/run/nod/web";
      }
      // cfg.environment;
      serviceConfig = {
        # The ETag is size + mtime, and every store file has mtime 1: after an update,
        # an index.html of the same size gets a 304 and clients load assets that are gone.
        ExecStartPre = "${pkgs.coreutils}/bin/cp -r --no-preserve=mode ${cfg.package}/lib/nod/dist/web /run/nod/web";
        RuntimeDirectory = "nod";
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = cfg.environmentFile;
        User = "nod";
        Group = "nod";
        SupplementaryGroups = [ "nod-runtime" ];
        StateDirectory = "nod";
        StateDirectoryMode = "0700";
        UMask = "0077";
        Restart = "on-failure";
        RestartSec = 5;
        IPAddressAllow = [ "localhost" ];
        IPAddressDeny = privateRanges;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        MemoryMax = "2G";
        TasksMax = 512;
      };
    };
  };
}
