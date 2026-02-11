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
            middlewares = [
              "sts-header@file"
              "rate-limit@file"
              "cloudflare-only@file"
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
          "rate-limit".rateLimit = {
            average = 100;
            burst = 50;
            period = "1m";
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
    ignoreIP = [ config.vars.lanSubnet ];
    jails.traefik = {
      filter = {
        Definition = {
          failregex = ''^<HOST> - \S+ \[.*\] \".*\" (401|403|429) .*$'';
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
