{
  self,
  config,
  pkgs,
  lib,
  ...
}:
let
  docker = lib.getExe pkgs.docker;
  sh = pkgs.runtimeShell;

  cloudflareIPs = [
    # IPv4 — https://www.cloudflare.com/ips-v4/
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
    # IPv6 — https://www.cloudflare.com/ips-v6/
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];

  accessLogPath = "${config.services.traefik.dataDir}/access.log";
in
{
  age.secrets = {
    traefikEnvFile.file = "${self}/secrets/traefik/env.age";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # HTTP/3
  networking.firewall.allowedUDPPorts = [
    443
  ];

  services.traefik = {
    enable = true;
    dataDir = "/opt/traefik";
    group = "docker";
    environmentFiles = [ config.age.secrets.traefikEnvFile.path ];
    staticConfigOptions = {
      global.checkNewVersion = false;
      providers = {
        docker = {
          network = "traefik";
          exposedByDefault = false;
          defaultRule = "Host(`{{ index .Labels \"com.docker.compose.service\" }}.${config.vars.domainName}`)";
        };
      };
      entryPoints = {
        web = {
          address = "${config.vars.staticIP}:80";
          forwardedHeaders.trustedIPs = cloudflareIPs;
          http = {
            redirections = {
              entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
          };
        };
        websecure = {
          address = "${config.vars.staticIP}:443";
          forwardedHeaders.trustedIPs = cloudflareIPs;
          http3 = {
            advertisedPort = 443;
          };
          http = {
            # cloudflare-only is attached per-router, not here: Cloudflare caps
            # proxied request bodies at 100MiB, which immich's single-shot
            # asset upload cannot chunk around, so immich is served DNS-only
            # and needs this entrypoint to accept direct connections.
            middlewares = [
              "sts-header@file"
            ];
            tls = {
              certResolver = "default";
              domains = [
                {
                  main = config.vars.domainName;
                  sans = [ "*.${config.vars.domainName}" ];
                }
              ];
            };
          };
        };
      };
      api = {
        dashboard = false;
      };
      ping = { };
      accessLog.filePath = accessLogPath;
      certificatesResolvers = {
        default = {
          acme = {
            email = config.vars.email;
            storage = "${config.services.traefik.dataDir}/acme.json";
            dnsChallenge = {
              provider = "cloudflare";
              # Bypass the local systemd-resolved stub (127.0.0.53): its
              # negative-caching of the pre-creation NXDOMAIN can outlast
              # lego's propagation check, causing renewal to time out even
              # though the TXT record is actually there.
              resolvers = [
                "1.1.1.1:53"
                "9.9.9.9:53"
              ];
            };
          };
        };
      };
    };
    dynamicConfigOptions = {
      http = {
        middlewares = {
          "sts-header" = {
            headers = {
              stsSeconds = 63072000;
            };
          };
          "cloudflare-only".ipAllowList = {
            sourceRange = cloudflareIPs;
          };
        };
      };
    };
  };

  services.fail2ban = {
    enable = true;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
    # Traefik logs the forwarded client IP, so LAN clients appear under their
    # own address and would otherwise be bannable by this jail.
    ignoreIP = [
      config.vars.lanSubnet
      config.vars.lanSubnet6
    ];
    jails.traefik = {
      filter = {
        Definition = {
          # 403 only. Traefik logs the forwarded client IP, so for the
          # Cloudflare-proxied routers a ban targets an address that never
          # connects here directly and matches nothing; the one router reachable
          # directly is immich, where 401 is simply the unauthenticated
          # response, so counting it would ban guests mid-upload. What is left
          # that 403 catches is worth catching: direct hits on the other hosts
          # are rejected by cloudflare-only, and those bans do apply.
          failregex = ''^<HOST> - \S+ \[.*\] \".*\" 403 .*$'';
          ignoreregex = "";
        };
      };
      settings = {
        backend = "auto";
        logpath = accessLogPath;
        maxretry = 10;
        findtime = 300;
        bantime = 3600;
      };
    };
  };

  systemd.services.docker-traefik-network = {
    description = "Ensure external Docker network 'traefik' exists";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${sh} -c '${docker} network inspect traefik >/dev/null 2>&1 || ${docker} network create traefik'";
    };
  };
}
