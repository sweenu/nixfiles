{
  description = "sweenu's hosts' setup";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    flake-parts.url = "github:hercules-ci/flake-parts";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixos";
    };

    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos";
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

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
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
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixos";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixos";
    };

    hyprland.url = "github:hyprwm/Hyprland/v0.53.1";

    nix-minecraft = {
      url = "github:sweenu/nix-minecraft";
      inputs.nixpkgs.follows = "nixos";
    };

    # PRs
    otbr.url = "github:NixOS/nixpkgs/pull/332296/head";
    restic.url = "github:NixOS/nixpkgs/pull/446825/head";
    dawarich.url = "github:NixOS/nixpkgs/pull/423867/head";
    n8n.url = "github:NixOS/nixpkgs/pull/460626/head";
    lldap.url = "github:NixOS/nixpkgs/pull/474570/head";
    uwsm.url = "github:NixOS/nixpkgs/pull/475312/head";
  };

  outputs =
    inputs@{
      self,
      nixos,
      flake-parts,
      haumea,
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

          devShells.default = import ./shell.nix { inherit config pkgs inputs'; };
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
              hostDirs = builtins.readDir path;
              validHosts = lib.filterAttrs (
                name: type: type == "directory" && builtins.pathExists (path + "/${name}/default.nix")
              ) hostDirs;
            in
            lib.mapAttrs (name: _: import (path + "/${name}")) validHosts;

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
              hyprland = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
              xdg-desktop-portal-hyprland =
                inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
              dawarich = inputs.dawarich.legacyPackages.${prev.stdenv.hostPlatform.system}.dawarich;
              uwsm = inputs.uwsm.legacyPackages.${prev.stdenv.hostPlatform.system}.uwsm;
            })
          ]
          ++ (overlaysFromDir ./overlays);

          extendedLib = lib.extend (final: prev: import ./lib.nix);

          commonModules = [
            inputs.agenix.nixosModules.age
            inputs.home.nixosModules.home-manager
            inputs.disko.nixosModules.disko
            inputs.arion.nixosModules.arion
            inputs.nix-minecraft.nixosModules.minecraft-servers
            "${inputs.otbr}/nixos/modules/services/home-automation/openthread-border-router.nix"
            "${inputs.restic}/nixos/modules/services/backup/restic.nix"
            "${inputs.dawarich}/nixos/modules/services/web-apps/dawarich.nix"
            "${inputs.n8n}/nixos/modules/services/misc/n8n.nix"
            "${inputs.lldap}/nixos/modules/services/databases/lldap.nix"
            {
              disabledModules = [
                "services/backup/restic.nix"
                "services/misc/n8n.nix"
                "services/databases/lldap.nix"
              ];
            }
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = hmModules ++ [
                inputs.nix-colors.homeManagerModules.default
                inputs.dms.homeModules.dank-material-shell
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
              desktop =
                base
                ++ [
                  profiles.audio
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
            extendedLib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit
                  self
                  inputs
                  suites
                  profiles
                  ;
                lib = extendedLib;
                nix-colors = inputs.nix-colors;
              };
              modules =
                commonModules
                ++ [
                  { networking.hostName = hostname; }
                  hosts.${hostname}
                ]
                ++ extraModules;
            };

        in
        {
          nixosConfigurations = {
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
                  path = inputs.deploy.lib.x86_64-linux.activate.nixos self.nixosConfigurations.najdorf;
                  user = "root";
                };
                sweenu = {
                  user = "sweenu";
                  sshUser = "root";
                  path =
                    inputs.deploy.lib.x86_64-linux.activate.home-manager
                      self.homeConfigurations."sweenu@najdorf";
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
                  path = inputs.deploy.lib.aarch64-linux.activate.nixos self.nixosConfigurations.ginko;
                  user = "root";
                };
              };
            };
          };

          checks = builtins.mapAttrs (
            system: deployLib: deployLib.deployChecks self.deploy
          ) inputs.deploy.lib;
        };
    };
}
