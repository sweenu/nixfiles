{
  description = "sweenu's hosts' setup";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    digga = {
      url = "github:divnix/digga";
      inputs = {
        nixpkgs.follows = "nixos";
        nixlib.follows = "nixos";
        home-manager.follows = "home";
        deploy.follows = "deploy";
        flake-utils-plus.follows = "flake-utils-plus";
      };
    };

    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos";
    };

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

    flake-utils-plus = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixos";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixos";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs =
    { self
    , nixos
    , nixos-hardware
    , digga
    , home
    , agenix
    , deploy
    , disko
    , arion
    , nix-colors
    , caelestia-shell
    , zen-browser
    , spicetify-nix
    , ...
    }@inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      channelsConfig.allowUnfree = true;
      channels.nixos = {
        imports = [ (digga.lib.importOverlays ./overlays) ];
        overlays = [
          ./pkgs/default.nix
          ./lib/default.nix
          agenix.overlays.default
          deploy.overlays.default
        ];
      };

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          imports = [ (digga.lib.importExportableModules ./modules) ];
          modules = [
            agenix.nixosModules.age
            home.nixosModules.home-manager
            disko.nixosModules.disko
            arion.nixosModules.arion
            spicetify-nix.nixosModules.spicetify
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts) ];

        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles;
          suites =
            with builtins;
            let
              explodeAttrs = set: map (a: getAttr a set) (attrNames set);
            in
            with profiles;
            rec {
              base = (explodeAttrs core) ++ [ vars ];
              server = [
                profiles.server
                vars
              ];
              desktop =
                base
                ++ [
                  audio
                  virt-manager
                ]
                ++ (explodeAttrs graphical)
                ++ (explodeAttrs pc)
                ++ (explodeAttrs hardware)
                ++ (explodeAttrs develop);
              laptop = desktop ++ [ profiles.laptop ];
            };
          inherit nix-colors;
        };

        hosts = {
          carokann.modules = [ nixos-hardware.nixosModules.framework-amd-ai-300-series ];
          grunfeld.system = "aarch64-linux";
          grunfeld.modules = [ nixos-hardware.nixosModules.raspberry-pi-3 ];
        };
      };

      home = {
        imports = [ (digga.lib.importExportableModules ./hm-modules) ];
        modules = [
          nix-colors.homeManagerModules.default
          caelestia-shell.homeManagerModules.default
          zen-browser.homeModules.twilight
        ];
      };

      devshell = ./shell;

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations {
        najdorf = {
          profilesOrder = [
            "system"
            "sweenu"
          ];
          profiles.system.sshUser = "root";
          profiles.sweenu = {
            user = "sweenu";
            sshUser = "root";
            path = deploy.lib.x86_64-linux.activate.home-manager self.homeConfigurations."sweenu@najdorf";
          };
        };
        grunfeld = {
          profiles.system.sshUser = "root";
        };
      };
    };
}
