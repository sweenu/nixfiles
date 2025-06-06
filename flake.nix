{
  description = "sweenu's hosts' setup";

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://sweenu.cachix.org"
      "https://deploy-rs.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "sweenu.cachix.org-1:DvQl16NWBp41k5IlxTODTOrIThyGRj8/ekrXxEheBQ0="
      "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.home-manager.follows = "home";
    digga.inputs.deploy.follows = "deploy";
    digga.inputs.flake-utils-plus.follows = "flake-utils-plus";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixos";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixos";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixos";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixos";
    nixos-anywhere.inputs.disko.follows = "disko";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixos";

    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixos";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";

    nix-colors.url = "github:misterio77/nix-colors";
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
          carokann.modules = [ nixos-hardware.nixosModules.framework-12th-gen-intel ];
          grunfeld.system = "aarch64-linux";
          grunfeld.modules = [ nixos-hardware.nixosModules.raspberry-pi-3 ];
        };
      };

      home = {
        imports = [ (digga.lib.importExportableModules ./hm-modules) ];
        modules = [ nix-colors.homeManagerModules.default ];
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
