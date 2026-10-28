{
  description = "sweenu's hosts' setup";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

    flake-parts.url = "github:hercules-ci/flake-parts";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixos";
    };

    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs = {
        nixpkgs.follows = "nixos";
        home-manager.follows = "home";
      };
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixos";
    };

    deploy = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixos";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs = {
        nixpkgs.follows = "nixos";
        disko.follows = "disko";
      };
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixos";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    dms = {
      url = "github:duxlabs-dev/dux-shell?ref=v2.0.0";
      inputs.nixpkgs.follows = "nixos";
    };

    dms-greeter = {
      url = "github:duxlabs-dev/dux-greeter?ref=v2.0.0";
      inputs.nixpkgs.follows = "nixos";
    };

    dms-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
      inputs.nixpkgs.follows = "nixos";
    };

    dankcalendar = {
      url = "github:duxlabs-dev/dux-calendar?ref=v2.0.0";
      inputs.nixpkgs.follows = "nixos";
    };

    dux-files = {
      url = "github:duxlabs-dev/dux-files?ref=v2.0.0";
      inputs.nixpkgs.follows = "nixos";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixos";
      inputs.home-manager.follows = "home";
    };

    # Private fork preserving vicrodh/qbz, whose upstream was deleted. Pinned to
    # the verified v2.0.2 commit; see pkgs/qbz.nix. git+ssh rather than github:
    # so the private repo authenticates via ssh instead of an access token.
    qbz-src = {
      url = "git+ssh://git@github.com/sweenu/qbz?rev=e537c7fd41d2bad7e39128c3bb7a5ae7effcbf8f";
      flake = false;
    };

    zed-kakoune = {
      url = "github:sweenu/zed/kakoune-v1.26.2-pre";
      # Must share the host's nixpkgs: Zed dlopens the Vulkan drivers from /run/opengl-driver
      inputs.nixpkgs.follows = "nixos";
    };

    # `delta` on PATH stays git-delta (home-manager's); the editor is launched
    # from its desktop entry or as `delta-app`.
    delta = {
      url = "github:zed-industries/delta-nix";
      # Upstream asks for the host's nixpkgs so Delta's glibc matches the
      # graphics stack it loads from /run/opengl-driver.
      inputs.nixpkgs.follows = "nixos";
    };

    nix-minecraft = {
      url = "github:sweenu/nix-minecraft/dev";
      inputs.nixpkgs.follows = "nixos";
    };

    relay-server = {
      url = "github:sweenu/relay-server";
      inputs.nixpkgs.follows = "nixos";
    };
    relay-control-plane = {
      url = "github:sweenu/control-plane";
      inputs.nixpkgs.follows = "nixos";
    };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixos";
    };

    luks-prompt-alert.url = "github:sweenu/luks-prompt-alert";

    hifiberry-nixos.url = "github:sweenu/hifiberry-nixos";
  };

  outputs =
    inputs@{
      self,
      nixos,
      flake-parts,
      haumea,
      nixpkgs-patcher,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixos {
            inherit system;
            config.allowUnfree = true;
          };

          treefmt = {
            programs = {
              nixfmt = {
                enable = true;
                excludes = [ "secrets/secrets.nix" ];
              };
            };
          };
        };

      flake =
        let
          inherit (nixos) lib;

          rakeLeaves =
            path:
            let
              loaded = haumea.lib.load {
                src = path;
                loader = haumea.lib.loaders.path;
              };
              liftDefaults =
                tree:
                lib.mapAttrs (
                  name: value:
                  if lib.isAttrs value then
                    if value ? default && lib.isPath value.default then value.default else liftDefaults value
                  else
                    value
                ) tree;
            in
            liftDefaults loaded;

          profiles = rakeLeaves ./profiles;

          overlaysFromDir =
            path:
            let
              content = builtins.readDir path;
              overlayFiles = lib.filterAttrs (
                name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
              ) content;
            in
            map (name: import (path + "/${name}")) (builtins.attrNames overlayFiles);

          importModules =
            path:
            let
              entries = lib.filesystem.listFilesRecursive path;
              nixFiles = builtins.filter (path: lib.hasSuffix ".nix" path) entries;
            in
            map import nixFiles;

          importHosts =
            path:
            let
              entries = builtins.readDir path;
              validHosts = lib.filterAttrs (
                name: type:
                (type == "directory" && builtins.pathExists (path + "/${name}/default.nix"))
                || (type == "regular" && lib.hasSuffix ".nix" name)
              ) entries;

              hostConfigs = lib.mapAttrs' (
                name: type:
                let
                  hostName = if type == "regular" then lib.removeSuffix ".nix" name else name;
                  hostPath = if type == "regular" then path + "/${name}" else path + "/${name}";
                in
                lib.nameValuePair hostName (import hostPath)
              ) validHosts;
            in
            hostConfigs;

          hosts = importHosts ./hosts // {
            ginko =
              { suites, ... }:
              {
                imports = suites.rpi;
              };
          };
          customModules = importModules ./modules;
          hmModules = importModules ./hm-modules;

          pkgsOverlay = import ./pkgs/default.nix;

          overlays = [
            pkgsOverlay
            inputs.agenix.overlays.default
            inputs.deploy.overlays.default
            inputs.nix-minecraft.overlay
            (final: prev: {
              relay-server = inputs.relay-server.packages.${prev.stdenv.hostPlatform.system}.default;
              relay-control-plane =
                inputs.relay-control-plane.packages.${prev.stdenv.hostPlatform.system}.default;
              qbz = prev.callPackage ./pkgs/qbz.nix { src = inputs.qbz-src; };
            })
          ]
          ++ (overlaysFromDir ./overlays);

          extendedLib = lib.extend (final: prev: import ./lib.nix);

          # deploy-rs' flake builds its `activate` binary from source against our
          # nixpkgs pin, so deploy-rs.cachix.org never has a matching hash and every
          # node embeds that build in its closure — on aarch64 that means a full Rust
          # build under qemu on each nixpkgs bump. nixpkgs ships a cached deploy-rs
          # for both arches, so keep deploy-rs' activation lib but point it at that
          # binary. basePkgs is deliberately unconfigured and un-overlaid so the
          # derivation matches exactly what Hydra built.
          deployLib = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
            system:
            let
              basePkgs = import inputs.nixos { inherit system; };
              deployPkgs = (basePkgs.extend inputs.deploy.overlays.default).extend (
                final: prev: {
                  deploy-rs = prev.deploy-rs // {
                    inherit (basePkgs) deploy-rs;
                  };
                }
              );
            in
            deployPkgs.deploy-rs.lib
          );

          commonModules = [
            inputs.agenix.nixosModules.age
            inputs.home.nixosModules.home-manager
            inputs.disko.nixosModules.disko
            inputs.arion.nixosModules.arion
            inputs.nix-minecraft.nixosModules.minecraft-servers
            inputs.relay-server.nixosModules.relay-server
            inputs.relay-control-plane.nixosModules.relay-control-plane
            inputs.luks-prompt-alert.nixosModules.default
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
              # Until: https://github.com/NixOS/nixpkgs/issues/526914
              nixpkgs.config.permittedInsecurePackages = [
                "electron-39.8.10"
              ];
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.sharedModules = hmModules ++ [
                inputs.nix-colors.homeManagerModules.default
                inputs.dms.homeModules.dank-material-shell
                inputs.dms-plugin-registry.nixosModules.default
                inputs.dankcalendar.homeModules.dank-calendar
                inputs.zen-browser.homeModules.twilight
              ];
            }
          ]
          ++ customModules;

          suites =
            let
              explodeAttrs = set: map (a: builtins.getAttr a set) (builtins.attrNames set);
            in
            rec {
              common = [
                profiles.common
                profiles.vars
              ];
              base = common ++ (explodeAttrs profiles.core);
              server = base ++ [ profiles.server ];
              rpi = common ++ [
                profiles.server
                profiles.rpi
              ];
              speakers = common ++ [ profiles.hifiberry ];
              desktop =
                base
                ++ [
                  profiles.audio
                  profiles.ssh
                  profiles.virt-manager
                ]
                ++ (explodeAttrs profiles.graphical)
                ++ (explodeAttrs profiles.pc)
                ++ (explodeAttrs profiles.hardware)
                ++ (explodeAttrs profiles.develop);
              laptop = desktop ++ [ profiles.laptop ];
            };

          mkHost =
            {
              hostname,
              system ? "x86_64-linux",
              extraModules ? [ ],
            }:
            nixpkgs-patcher.lib.nixosSystem {
              inherit system;
              nixpkgsPatcher.nixpkgs = inputs.nixos;
              specialArgs = inputs // {
                inherit
                  self
                  inputs
                  suites
                  profiles
                  ;
                lib = extendedLib;
              };
              modules =
                commonModules
                ++ [
                  { networking.hostName = hostname; }
                  hosts.${hostname}
                ]
                ++ extraModules;
            };

          # The speakers run hifiberry-nixos' own nixosSystem, which brings the
          # Raspberry Pi board support and the HiFiBerryOS module with it.
          mkSpeakersHost =
            hostname:
            inputs.hifiberry-nixos.lib.nixosSystem {
              board = "rpi4";
              specialArgs = {
                inherit
                  self
                  inputs
                  suites
                  profiles
                  ;
              };
              modules = customModules ++ [ hosts.${hostname} ];
            };

          mkSpeakersDeployNode = name: {
            hostname = self.nixosConfigurations.${name}.config.networking.hostName;
            remoteBuild = false;
            fastConnection = true;
            profiles.system = {
              sshUser = "root";
              path = deployLib.aarch64-linux.activate.nixos self.nixosConfigurations.${name};
              user = "root";
            };
          };

          speakerHosts = [
            "bedroom-speakers"
            "livingroom-speakers"
          ];

        in
        {
          nixosConfigurations = {
            bootstrap = mkHost {
              hostname = "bootstrap";
            };

            carokann = mkHost {
              hostname = "carokann";
              extraModules = [ inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series ];
            };

            najdorf = mkHost {
              hostname = "najdorf";
            };

            ginko = mkHost {
              hostname = "ginko";
              system = "aarch64-linux";
              extraModules = [ inputs.nixos-hardware.nixosModules.raspberry-pi-3 ];
            };

          }
          // lib.genAttrs speakerHosts mkSpeakersHost;

          nixOnDroidConfigurations.phone = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
            pkgs = import inputs.nixos {
              system = "aarch64-linux";
              overlays = overlays ++ [ inputs.nix-on-droid.overlays.default ];
              config.allowUnfree = true;
            };
            home-manager-path = inputs.home.outPath;
            extraSpecialArgs = inputs // {
              inherit
                self
                inputs
                suites
                profiles
                ;
            };
            modules = [
              {
                home-manager = {
                  useGlobalPkgs = true;
                  backupFileExtension = "hm-bak";
                  sharedModules = hmModules ++ [ inputs.nix-colors.homeManagerModules.default ];
                };
              }
              hosts.phone
            ];
          };

          homeConfigurations =
            let
              mkHomeConfigs =
                name: config:
                let
                  hmUsers = config.config.home-manager.users or { };
                in
                lib.mapAttrs' (user: cfg: lib.nameValuePair "${user}@${name}" cfg.home) hmUsers;
            in
            lib.foldl' (acc: name: acc // (mkHomeConfigs name self.nixosConfigurations.${name})) { } (
              builtins.attrNames self.nixosConfigurations
            );

          deploy.nodes = {
            najdorf = {
              hostname = "najdorf";
              remoteBuild = true;
              fastConnection = true;
              profilesOrder = [
                "system"
                "sweenu"
              ];
              profiles = {
                system = {
                  sshUser = "root";
                  path = deployLib.x86_64-linux.activate.nixos self.nixosConfigurations.najdorf;
                  user = "root";
                };
                sweenu = {
                  user = "sweenu";
                  sshUser = "root";
                  path = deployLib.x86_64-linux.activate.home-manager self.homeConfigurations."sweenu@najdorf";
                };
              };
            };

            ginko = {
              hostname = "ginko";
              remoteBuild = false;
              fastConnection = true;
              profiles = {
                system = {
                  sshUser = "root";
                  path = deployLib.aarch64-linux.activate.nixos self.nixosConfigurations.ginko;
                  user = "root";
                };
              };
            };

          }
          // lib.genAttrs speakerHosts mkSpeakersDeployNode;

          checks = builtins.mapAttrs (system: dl: dl.deployChecks self.deploy) deployLib;
        };
    };
}
