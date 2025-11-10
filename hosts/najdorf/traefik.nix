{
  self,
  config,
  ...
}:

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
          address = ":80";
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
          address = ":443";
          http3 = {
            advertisedPort = 443;
          };
          http = {
            middlewares = [ "sts-header@file" ];
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
        dashboard = true;
        insecure = false;
      };
      ping = { };
      accessLog = { };
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
        };
        routers.dashboard = {
          rule = "Host(`traefik.${config.vars.domainName}`)";
          service = "api@internal";
          middlewares = [ "authelia" ];
        };
      };
    };
  };
}
